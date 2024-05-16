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
  
      debugShowCheckedModeBanner: false, 
      title: 'My App of Users',      
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey),
        scaffoldBackgroundColor: Color.fromARGB(255, 181, 184, 137),
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

  final TextEditingController titleController = TextEditingController();
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
        title: const Text('List of Users'),
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
            return Center(child: Text("Error: ${snapshot.error}"));
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
            'Add User',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          TextFormField(
            controller: firstnameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextFormField(
            controller: lastnameController,
            decoration: const InputDecoration(labelText: 'Lastname'),
          ),
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'E-mail'),
          ),
          TextFormField(
            controller: pictureController,
            decoration: const InputDecoration(labelText: 'URL Picture'),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: _createUser,
                child: const Text('Add'),
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
            title: titleController.text,
            firstName: firstnameController.text,
            lastName: lastnameController.text,
            email: emailController.text,
            picture: pictureController.text,
          ))
          .then((newUser) {
        _showSnackbar('User added successfully!');
        _refreshUserList();
        setState(() {
          _addingUser = false;
        });
      }).catchError((error) {
        _showSnackbar('Failed to add user: $error');
      });
    } else {
      _showSnackbar('Please fill in all fields.');
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
    titleController.text = user.title;
    firstnameController.text = user.firstName;
    lastnameController.text = user.lastName;
    emailController.text = user.email;
    pictureController.text = user.picture;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit User"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextFormField(
                controller: firstnameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: lastnameController,
                decoration: const InputDecoration(labelText: 'Lastname'),
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
              ),
              TextFormField(
                controller: pictureController,
                decoration:
                    const InputDecoration(labelText: 'URL Picture'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("To update"),
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
      'title': titleController.text,
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
        _showSnackbar('User updated successfully!');
        _refreshUserList();
      }).catchError((error) {
        _showSnackbar('Falled to update user: $error');
      });
    } else {
      _showSnackbar('Please fill in all fields.');
    }
  }

  void _deleteUser(String id) {
    userService.deleteUser(id).then((_) {
      _showSnackbar('User deleted successfully!');
      _refreshUserList();
    }).catchError((error) {
      _showSnackbar('Failed to delete user: $error.');
    });
  }
}
