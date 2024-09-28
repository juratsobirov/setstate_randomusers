import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:randomusers_setstate/services/log_service.dart';

import '../models/random_user_list_res.dart';
import '../services/http_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;
  List<RandomUser> userList = [];
  ScrollController scrollController = ScrollController();
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadRandomUserList();

    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent <=
          scrollController.offset) {
        _loadRandomUserList();
      }
    });
  }

  _loadRandomUserList() async {
    var response = await Network.GET(Network.API_RANDOM_USER_LIST,
        Network.paramsRandomUserList(currentPage));
    LogService.i(response!);
    var randomUserListRes = Network.parseRandomUserList(response);
    currentPage = randomUserListRes.info.page + 1;
    setState(() {
      userList.addAll(randomUserListRes.results);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(232, 232, 232, 1),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Random User - SetState"),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              return _itemOfRendomUser(userList[index], index);
            },
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _itemOfRendomUser(RandomUser randomUser, int index) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(
        top: 5,
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          CachedNetworkImage(
            height: 80,
            width: 80,
            fit: BoxFit.cover,
            imageUrl: randomUser.picture.medium,
            placeholder: (context, url) => Container(
              height: 80,
              width: 80,
              color: Colors.grey,
            ),
            errorWidget: (context, url, error) => Container(
              height: 80,
              width: 80,
              color: Colors.grey,
              child: Icon(Icons.error),
            ),
          ),
          SizedBox(
            width: 16,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${index} - ${randomUser.name.first} ${randomUser.name.last}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                Text(
                  randomUser.email,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                Text(
                  randomUser.cell,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
