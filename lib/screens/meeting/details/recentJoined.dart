import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jagu_meet/firebase/databases/usersCloudDb.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jagu_meet/widgets/dialogs.dart';
import 'package:jagu_meet/widgets/loading.dart';
import 'package:jagu_meet/widgets/quiet_box.dart';
import 'package:provider/provider.dart';
import 'meetDetails.dart';
import 'package:timeago/timeago.dart' as timeago;

class RecentJoined extends StatefulWidget {
  final name;
  final email;
  final uid;
  final url;
  const RecentJoined({Key key,
    @required this.name,
    this.email,
    this.uid,
    this.url,})
      : super(key: key);

  @override
  _RecentJoinedState createState() => _RecentJoinedState(name, email, uid, url);
}

class _RecentJoinedState extends State<RecentJoined> {
  final name;
  final email;
  final uid;
  final url;
  _RecentJoinedState(this.name, this.email, this.uid, this.url);
  DatabaseService databaseService = new DatabaseService();

  var _userUid;
  getInfo() {
    setState(() {
      _userUid = uid;
    });
  }

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return Theme(
      data: themeNotifier.getTheme(),
      child: Scaffold(
        backgroundColor: themeNotifier.getTheme() == darkTheme
            ? Color(0xFF191919)
            : Colors.white,
        appBar: AppBar(
          iconTheme: themeNotifier.getTheme() == darkTheme
              ? IconThemeData(color: Colors.white)
              : IconThemeData(color: Colors.black),
          backgroundColor: themeNotifier.getTheme() == darkTheme
              ? Color(0xFF191919)
              : Colors.white,
          elevation: 0,
          bottom: PreferredSize(
              child: Divider(
                  height: 1,
                  color: themeNotifier.getTheme() == darkTheme
                      ?  Color(0xFF303030) : Colors.black12
              ),
              preferredSize: Size(double.infinity, 0.0)) ,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_sharp),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Recent Meetings',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: themeNotifier.getTheme() == darkTheme
                  ? Colors.white : Colors.black54,
            ),
          ),
        ),
        body: SafeArea(
          child: Container(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Users')
                    .doc(_userUid)
                    .collection('Joined').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Loading();
                  }
                  if (snapshot.hasError) {
                    return Loading();
                  }
                  return snapshot.data.docs.length == 0
                      ? QuietBox(
                    heading: "This is where all your recent joined meetings are listed",
                    subtitle:
                    "There are no recent joined meetings, join one now",
                  )
                      : Container(
                    height: double.maxFinite,
                    width: double.maxFinite,
                    child: SingleChildScrollView(
                      child: Column(children: [
                        ListView.separated(
                          shrinkWrap: true,
                          itemCount: snapshot.data.docs.length,
                          separatorBuilder:
                              (BuildContext context, int index) {
                            return Divider(
                              height: 1,
                              color: themeNotifier.getTheme() == darkTheme
                                  ? Color(0xFF242424)
                                  : Colors.black12,
                              indent: 15,
                              endIndent: 0,
                            );
                          },
                          itemBuilder:
                              (BuildContext context, int position) {
                            return ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) =>
                                              meetDetails(db: 'join',
                                                id: snapshot.data
                                                    .docs[position]["id"],
                                                name: widget.name,
                                                email: widget.email,
                                                PhotoUrl: widget.url,
                                                uid: widget.uid,
                                                time: snapshot.data
                                                    .docs[position]["time"].toDate().toString(),)));
                                },
                                visualDensity: VisualDensity(
                                    horizontal: 0, vertical: -4),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.horizontal(
                                        right: Radius.circular(0),
                                        left: Radius.circular(0))),
                                trailing: Text(
                                  snapshot.data.docs[position]["id"],
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: themeNotifier.getTheme() ==
                                        darkTheme
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                ),
                                title: Text(
                                  snapshot.data.docs[position]["meetName"],
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: themeNotifier.getTheme() ==
                                        darkTheme
                                        ? Colors.white
                                        : Colors.black54,
                                  ),
                                ),
                                subtitle: Text(
                                  timeago
                                      .format(DateTime.parse(
                                      snapshot.data.docs[position]["time"].toDate().toString())),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: themeNotifier.getTheme() ==
                                        darkTheme
                                        ? Colors.white
                                        : Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                        Divider(
                          height: 1,
                          color: themeNotifier.getTheme() == darkTheme
                              ? Color(0xFF303030)
                              : Colors.black12,
                        ),
                      ]),
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }
}
