import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:jagu_meet/firebase/databases/appCloudDb.dart';
import 'package:jagu_meet/model/searchMeet.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _mainUserCollection = _firestore.collection('Users');
final CollectionReference _mainMeetCollection = _firestore.collection('Meetings');
final CollectionReference _mainLiveCollection = _firestore.collection('Live');
final now = DateTime.now();

class DatabaseService {
 AppCloudService appService  = new AppCloudService();

  Future<void> addUser(uid, name, email, phone, avatar) async {
    Map<String, dynamic> data = <String, dynamic>{
      "name": name,
      "email": email,
      "uid": uid,
      "avatar": avatar,
      "phoneno": phone,
      "plan": 'basic',
    };

    await _mainUserCollection
        .doc(uid)
        .set(data)
        .whenComplete(() => print("New user added!"))
        .catchError((e) => print(e));
  }

  Future<String> createMeeting() async {
   // var random = randomNumeric(11).toString();
    var random;
    try {
      await FirebaseFirestore.instance.doc("$_mainMeetCollection/$random").get().then((doc) async {
        if (doc.exists) {
          await FirebaseFirestore.instance.doc("$_mainMeetCollection/$random").get().then((doc) async {
            if (doc.exists) {
              await FirebaseFirestore.instance.doc("$_mainMeetCollection/$random").get().then((doc) async {
                if (doc.exists) {

                } else {
                  return random;
                }});
            } else {
              return random;
            }});
        } else {
          return random;
        }});

    } catch (e) {
      print(e);
    }
  }

  Future<void> participantJoined(uid, id, name, email, url, joined, left) async {
    Map<String, dynamic> data = <String, dynamic>{
      "name": name,
      "email": email,
      "avatar": url,
      "joined": joined,
      "left": left,
    };

    try {
      await FirebaseFirestore.instance.doc("Users/$uid/Hosted/$id/Participants/uid").get().then((doc) async {
        if (doc.exists) {

        } else {
          await _mainUserCollection
              .doc(uid)
              .collection('Hosted')
              .doc(id)
              .collection('Participants')
              .doc(uid)
              .set(data)
              .whenComplete(() => print("participants added!"))
              .catchError((e) => print(e));
        }});

    } catch (e) {
      print(e);
    }
  }

  Future<void> participantLeft(uid, id) async {
    Map<String, dynamic> data = <String, dynamic>{
      "left": DateFormat('hh:mm a').format(DateTime.now()).toString(),
    };

    await _mainUserCollection
        .doc(uid)
        .collection('Hosted')
        .doc(id)
        .collection('Participants')
        .doc(uid)
        .update(data)
        .whenComplete(() => print("participants updated!"))
        .catchError((e) => print(e));
  }

  Future<void> deleteParticipant(uid, id) async {
    QuerySnapshot querySnapshot =
    await _mainUserCollection
        .doc(uid)
        .collection('Hosted')
        .doc(id)
        .collection('Participants').get();
    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> updateUser(String plan, uid) async {
    Map<String, dynamic> data = <String, dynamic>{
      "plan": plan,
    };

    await _mainUserCollection
        .doc(uid)
        .update(data)
        .whenComplete(() => print("New user added!"))
        .catchError((e) => print(e));
  }

  Future<void> addMyJoined(String meetId, uid, meetName, time, name, email, url) async {
    Map<String, dynamic> data = <String, dynamic>{
      "id": meetId,
      "meetName": meetName,
      "time": time
    };

    await _mainUserCollection
        .doc(uid)
        .collection('Joined')
        .doc(meetId)
        .set(data)
        .whenComplete(() => print("Joined meeting added!"))
        .catchError((e) => print(e));

    await addAllMeets(meetId, uid, meetName, 'join', time);
    await participantJoined(uid, meetId, name, email, url, DateFormat('hh:mm a').format(DateTime.now()).toString(), DateFormat('hh:mm a').format(DateTime.now()).toString());
  }

  Future<void> addMyScheduled(String meetId, uid, meetName, date, from, repeat) async {
    Map<String, dynamic> data = <String, dynamic>{
      "id": meetId,
      "meetName": meetName,
      "date": date,
      "from": from,
      "repeat": repeat,
    };

    await _mainUserCollection
        .doc(uid)
        .collection('Scheduled')
        .doc(meetId)
        .set(data)
        .whenComplete(() => print("Scheduled meeting added!"))
        .catchError((e) => print(e));

    addAllMeets(meetId, uid, meetName, 'schedule', from);
  }

  Future<void> addMyHosted(String meetId, meetName, uid , time) async {
    Map<String, dynamic> data = <String, dynamic>{
      "id": meetId,
      "meetName": meetName,
      "time": time,
    };

    await _mainUserCollection
        .doc(uid)
        .collection('Hosted')
        .doc(meetId)
        .set(data)
        .whenComplete(() => print("Scheduled meeting added!"))
        .catchError((e) => print(e));

    addAllMeets(meetId, uid, meetName, 'host', time);
    deleteParticipant(uid, meetId);
  }

  Future<void> addAllMeets(String meetId, uid, meetName, type, time) async {
    Map<String, dynamic> data = <String, dynamic>{
      "id": meetId,
      "meetName": meetName,
      "type": type,
      "time": time.toString(),
    };

    await _mainUserCollection
        .doc(uid)
        .collection('AllMeetings')
        .doc(meetId)
        .set(data)
        .whenComplete(() => print("all meeting added!"))
        .catchError((e) => print(e));
  }

  Future<void> addHosted(bool started, String id, uid, host, meetName, time, ch, live, record, raise, yt, kick) async {
    Map<String, dynamic> data = <String, dynamic>{
      "host": host,
      "hasStarted": started,
      "id": id,
      "meetName": meetName,
      "chat": ch,
      "live": live,
      "record": record,
      "raise": raise,
      "yt": yt,
      "kick": kick,
    };

    await _mainMeetCollection
        .doc(id)
        .set(data)
        .whenComplete(() => print("Hosted meeting added!"))
        .catchError((e) => print(e));

    await addMyHosted(id, meetName, uid, time);
    await appService.totalHosted();
  }

  Future<void> addScheduledHosted(bool started, String uid,  host, id,  meetName, date, from, to, repeat, ch, live, record, raise, yt, kick) async {
    Map<String, dynamic> data = <String, dynamic>{
      "host": host,
      "hasStarted": started,
      "meetName": meetName,
      "id": id,
      "date": date,
      "from": from,
      "to": to,
      "repeat" : repeat,
      "chat": ch,
      "live": live,
      "record": record,
      "raise": raise,
      "yt": yt,
      "kick": kick,
    };

    await _mainMeetCollection
        .doc(id)
        .set(data)
        .whenComplete(() => print("Scheduled Hosted meeting added!"))
        .catchError((e) => print(e));

    await addMyScheduled(id, uid, meetName, date, from, repeat);
    await appService.totalHosted();
  }

  Future<void> updateMyScheduled(String meetId, uid, meetName, date, from, repeat) async {
    Map<String, dynamic> data = <String, dynamic>{
      "id": meetId,
      "meetName": meetName,
      "date": date,
      "from": from,
      "repeat": repeat,
    };

    await _mainUserCollection
        .doc(uid)
        .collection('Scheduled')
        .doc(meetId)
        .set(data)
        .whenComplete(() => print("Scheduled meeting added!"))
        .catchError((e) => print(e));

    addAllMeets(meetId, uid, meetName, 'schedule', from);
  }

  Future<void> updateMyHosted(String meetId, meetName, uid, time) async {
    Map<String, dynamic> data = <String, dynamic>{
      "id": meetId,
      "meetName": meetName,
      "time": time,
    };

    await _mainUserCollection
        .doc(uid)
        .collection('Hosted')
        .doc(meetId)
        .set(data)
        .whenComplete(() => print("Hosted meeting updated!"))
        .catchError((e) => print(e));

    addAllMeets(meetId, uid, meetName, 'host', time);
    deleteParticipant(uid, meetId);
  }

  Future<void> updateScheduledHosted(uid, id, meetName, date, from, to, repeat, ch, live, record, raise, yt, kick, host, started) async {
    Map<String, dynamic> data = <String, dynamic>{
      "host": host,
      "hasStarted": started,
      "meetName": meetName,
      "id": id,
      "date": date,
      "from": from,
      "to": to,
      "repeat" : repeat,
      "chat": ch,
      "live": live,
      "record": record,
      "raise": raise,
      "yt": yt,
      "kick": kick,
    };

    await _mainMeetCollection
        .doc(id)
        .set(data)
        .whenComplete(() => print("Scheduled Hosted meeting added!"))
        .catchError((e) => print(e));

    await updateMyScheduled(id, uid, meetName, date, from, repeat);
    await appService.totalHosted();
  }

  Future<void> startScheduledHosted(id, started) async {
    Map<String, dynamic> data = <String, dynamic>{
      "hasStarted": started,
    };

    await _mainMeetCollection
        .doc(id)
        .update(data)
        .whenComplete(() => print("Scheduled Hosted meeting added!"))
        .catchError((e) => print(e));

  }

  Future<void> updateHosted(uid, id, String meetName, ch, live, record, raise, yt, kick, host, time, started) async {
    Map<String, dynamic> data = <String, dynamic>{
      "host": host,
      "hasStarted": started,
      "id": id,
      "meetName": meetName,
      "chat": ch,
      "live": live,
      "record": record,
      "raise": raise,
      "yt": yt,
      "kick": kick,
    };

    await _mainMeetCollection
        .doc(id)
        .set(data)
        .whenComplete(() => print("Hosted meeting updated!"))
        .catchError((e) => print(e));
    await updateMyHosted(id, meetName, uid, time);
    await appService.totalHosted();
  }

  Future<void> addLive(String id, host, name, meetName) async {
    Map<String, dynamic> data = <String, dynamic>{
      "host": host,
      "name": name,
      "id": id,
      "time": DateFormat.jm().format(now.toUtc()).toString(),
      "meetName": meetName,
    };

    await _mainLiveCollection
    .doc(id)
        .set(data)
        .whenComplete(() => print("Hosted meeting added!"))
        .catchError((e) => print(e));

    await appService.totalHosted();
  }

  Future removeMyScheduled(meetId, uid) async {
    await _mainUserCollection
        .doc(uid)
        .collection('Scheduled')
        .doc(meetId).delete();
    await removeHosted(meetId);
    await removeAllMeets(meetId, uid);
    try {
      await FirebaseFirestore.instance.doc("Users/$uid/Hosted/$meetId").get().then((doc) {
        if (doc.exists) {
          removeSchFromHosted(meetId, uid);
        } else {

        }});

    } catch (e) {
      print(e);
    }
  }

  Future removeAllMeets(meetId, uid) async {
    await _mainUserCollection
        .doc(uid)
        .collection('AllMeetings')
        .doc(meetId).delete();
  }

  Future removeHosted(meetId) async {
    await _mainMeetCollection
        .doc(meetId)
        .delete();
  }

  Future removeLive(meetId) async {
    await _mainLiveCollection
        .doc(meetId)
        .delete();
  }

  Future removeMyJoined(meetId, uid) async {
    await _mainUserCollection
        .doc(uid)
        .collection('Joined')
        .doc(meetId).delete();
    await removeAllMeets(meetId, uid);

  }

  Future removeMyHosted(meetId, uid) async {
    await _mainUserCollection
        .doc(uid)
        .collection('Hosted')
        .doc(meetId).delete();
    await removeHosted(meetId);
    await removeAllMeets(meetId, uid);
  }

  Future removeSchFromHosted(meetId, uid) async {
    await _mainUserCollection
        .doc(uid)
        .collection('Hosted')
        .doc(meetId).delete();
  }

  Future<List<SearchMeet>> fetchAllMeets(uid) async {
    List<SearchMeet> meetList = [];

    QuerySnapshot querySnapshot =
    await _mainUserCollection
        .doc(uid)
        .collection('AllMeetings').get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      meetList.add(SearchMeet.fromMap(querySnapshot.docs[i].data()));
    }
    return meetList;
  }
}