import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:glboard_web/src/constants.dart';
import 'package:glboard_web/src/features/individual_analysis/individual_analysis_page.dart';
import 'package:glboard_web/src/features/list_players/list_players_controller.dart';
import 'package:glboard_web/src/features/sidebar/sider_bar.dart';
import 'package:glboard_web/src/shared/widgets.dart';
import 'package:provider/provider.dart';

class ListPlayers extends StatefulWidget {
  const ListPlayers({Key? key}) : super(key: key);
  @override
  _ListPlayersState createState() => _ListPlayersState();
}

class _ListPlayersState extends State<ListPlayers> {
  late final ListPlayersController controller;

  @override
  void initState() {
    super.initState();
    if (globalUserModel.iduser.isEmpty) {
      Navigator.of(context).pushReplacementNamed('/auth');
    }

    controller = context.read<ListPlayersController>();

    controller.addListener(() {
      if (controller.state == ListPlayersState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(controller.error)),
        );
      } else if (controller.state == ListPlayersState.success) {
        // Navigator.of(context).pushReplacementNamed('/auth');
      }
    });

    //! TODO -> Não sei sei se é a melhor solução, porém chamada o fetch somente no fim do ciclo do initstate
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      controller.fetchPlayersGame(
        selectedGameID,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(),
      drawer: const NavigationDrawerWidget(),
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Lista de Jogadores",
              style: TextStyle(fontSize: 35),
            ),
            const SizedBox(height: 20),
            ListViewPlayers(
              selectedGameID,
            ),
          ],
        ),
      ),
    );
  }
}

class ListViewPlayers extends StatelessWidget {
  final String gameID;

  const ListViewPlayers(this.gameID, {Key? key}) : super(key: key);

  void goToIndividualAnalysis(context, String gameUserId) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      settings: const RouteSettings(name: '/individual_analysis'),
      builder: (context) => IndividualAnalysis(gameUserId),
    ));
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final controller = context.watch<ListPlayersController>();

    return controller.state != ListPlayersState.loading
        ? Container(
            alignment: Alignment.center,
            width: size.width - 100,
            height: size.height - 300,
            child: CommonWidgets.table(
              [
                "Nome do Jogador",
                "Ultima Sessão",
                "% Conclusão",
                "Chave Jogador",
              ],
              List.generate(controller.playersModel.length, (index) {
                return [
                  controller.playersModel[index].name,
                  controller.playersModel[index].lastLogin,
                  controller.playersModel[index].conclusionPhases.toString(),
                  controller.playersModel[index].apiUser,
                ];
              }),
              clicked: true,
              columnClick: 3,
              function: (value) => goToIndividualAnalysis(context, value),
            ),
          )
        : CommonWidgets.loading();
  }
}
