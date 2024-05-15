# **foi feito:**

# **Adição de Listagem de Usuários e Formulário de Adição:**

* Foram adicionados métodos _buildUserList e _buildAddUserForm na classe UserListScreenState para exibir a lista de usuários e o formulário de adição de usuário, respectivamente.
* A lógica para alternar entre a exibição da lista de usuários e o formulário de adição foi implementada no método _buildBody.
* Foi adicionado um novo estado _selectedIndex para controlar o índice selecionado na barra de navegação inferior e atualizar a interface de acordo.
* Adição de BottomNavigationBar:

* Foi adicionado um BottomNavigationBar na parte inferior da tela para permitir a navegação entre a lista de usuários e o formulário de adição de usuário.
* Implementação de Operações CRUD:

* Foram adicionados métodos _addUser, _showEditDialog, _updateUser e _deleteUser na classe UserListScreenState para lidar com as operações CRUD (Create, Read, Update, Delete) de usuários.
* Esses métodos interagem com o serviço UserService para enviar solicitações HTTP correspondentes para criar, editar e excluir usuários.
* Atualização da Exibição da Lista de Usuários:

* A lista de usuários é exibida usando um ListView.builder no método _buildUserList, que busca os usuários do servidor por meio do serviço UserService.
* Cada item da lista exibe as informações do usuário e permite editar ou excluir o usuário correspondente.
* Atualização da Exibição do Formulário de Adição:

* O formulário de adição de usuário contém campos para inserir o nome, sobrenome e e-mail do usuário. Quando enviado, os dados são enviados para o servidor para criar um novo usuário.
* Atualizações no UserService:

* O UserService permaneceu praticamente inalterado, exceto pelos ajustes para criar, editar e excluir usuários conforme necessário para atender às solicitações do aplicativo.
* Essas são as principais modificações e adições feitas no código para implementar as funcionalidades de listagem, adição, edição e exclusão de usuários no aplicativo
