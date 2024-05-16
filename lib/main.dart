import 'package:flutter/material.dart';
import 'user.dart';
import 'user_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Oculta o banner "debug"
      debugShowCheckedModeBanner: false,
      title: 'Meu Aplicativo de Usuários',      
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const UserListScreen(),
    );
  }
}

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  UserListScreenState createState() => UserListScreenState();
}

class UserListScreenState extends State<UserListScreen> {
  late Future<List<User>> futureUsers;
  final UserService userService = UserService();

  final TextEditingController tituloController = TextEditingController();
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pictureController = TextEditingController();

  bool _addingUser = false;

  @override
  void initState() {
    super.initState();
    futureUsers = userService.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Usuários'),
      ),
      body: _addingUser ? _buildAddUserForm() : _buildUserList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _addingUser = !_addingUser;
          });
        },
        child: Icon(_addingUser ? Icons.close : Icons.add),
      ),
    );
  }

  Widget _buildUserList() {
    return FutureBuilder<List<User>>(
      future: futureUsers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          }
          return ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index) {
              User user = snapshot.data![index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.picture),
                ),
                title: Text(
                  '${user.firstName} ${user.lastName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  user.email,
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditDialog(user),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteUser(user.id),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildAddUserForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Adicionar Usuário',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          TextFormField(
            controller: firstnameController,
            decoration: const InputDecoration(labelText: 'Nome'),
          ),
          TextFormField(
            controller: lastnameController,
            decoration: const InputDecoration(labelText: 'Sobrenome'),
          ),
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'E-mail'),
          ),
          TextFormField(
            controller: pictureController,
            decoration: const InputDecoration(labelText: 'URL da Foto'),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: _createUser,
                child: const Text('Adicionar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _createUser() {
    if (firstnameController.text.isNotEmpty &&
        lastnameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        pictureController.text.isNotEmpty) {
      userService
          .createUser(User(
            id: '',
            title: tituloController.text,
            firstName: firstnameController.text,
            lastName: lastnameController.text,
            email: emailController.text,
            picture: pictureController.text,
          ))
          .then((newUser) {
        _showSnackbar('Usuário adicionado com sucesso!');
        _refreshUserList();
        setState(() {
          _addingUser = false;
        });
      }).catchError((error) {
        _showSnackbar('Falha ao adicionar usuário: $error');
      });
    } else {
      _showSnackbar('Por favor, preencha todos os campos.');
    }
  }

  void _refreshUserList() {
    setState(() {
      futureUsers = userService.getUsers();
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showEditDialog(User user) {
    tituloController.text = user.title;
    firstnameController.text = user.firstName;
    lastnameController.text = user.lastName;
    emailController.text = user.email;
    pictureController.text = user.picture;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Usuário"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextFormField(
                controller: firstnameController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextFormField(
                controller: lastnameController,
                decoration: const InputDecoration(labelText: 'Sobrenome'),
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
              ),
              TextFormField(
                controller: pictureController,
                decoration:
                    const InputDecoration(labelText: 'URL da Foto'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("Atualizar"),
            onPressed: () {
              _updateUser(user);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _updateUser(User user) {
    Map<String, dynamic> dataToUpdate = {
      'title': tituloController.text,
      'firstName': firstnameController.text,
      'lastName': lastnameController.text,
      'email': emailController.text,
      'picture': pictureController.text,
    };

    if (firstnameController.text.isNotEmpty &&
        lastnameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        pictureController.text.isNotEmpty) {
      userService.updateUser(user.id, dataToUpdate).then((updatedUser) {
        _showSnackbar('Usuário atualizado com sucesso!');
        _refreshUserList();
      }).catchError((error) {
        _showSnackbar('Falha ao atualizar usuário: $error');
      });
    } else {
      _showSnackbar('Por favor, preencha todos os campos.');
    }
  }

  void _deleteUser(String id) {
    userService.deleteUser(id).then((_) {
      _showSnackbar('Usuário excluído com sucesso!');
      _refreshUserList();
    }).catchError((error) {
      _showSnackbar('Falha ao excluir usuário.');
    });
  }
}
