import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jagu_meet/firebase/ads/admobAds.dart';
import 'package:jagu_meet/firebase/databases/usersCloudDb.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';

class StartLive extends StatefulWidget {
  final name;
  final email;
  final url;
  const StartLive({this.name,
    this.email,
  this.url, Key key}) : super(key: key);

  @override
  _StartLiveState createState() => _StartLiveState();
}


class _StartLiveState extends State<StartLive> {
  final serverText = TextEditingController();
  DatabaseService databaseService = new DatabaseService();
  AdHelper adHelper = new AdHelper();

  final _titleController = new TextEditingController();

  bool isButtonEnabled;
  isEmpty() {
    if (_titleController.text != "") {
      setState(() {
        isButtonEnabled = true;
      });
    } else {
      setState(() {
        isButtonEnabled = false;
      });
    }
  }

  @override
  void initState() {
    isEmpty();
    adHelper.interstitialAdload();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return Theme(
        data: themeNotifier.getTheme(),
    child:
      Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.clear,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        iconTheme: IconThemeData(
            color: themeNotifier.getTheme() == darkTheme
                ? Colors.white : Colors.black54),
        backgroundColor: themeNotifier.getTheme() == darkTheme
            ? Color(0xff0d0d0d)
            : Color(0xffffffff),
        elevation: 0,
        bottom: PreferredSize(
            child: Divider(
                height: 1,
                color: themeNotifier.getTheme() == darkTheme
                    ? Color(0xFF303030) : Colors.black12
            ),
            preferredSize: Size(double.infinity, 0.0)),
        title: Text(
          'Start a Stage',
          style: TextStyle(
            color: themeNotifier.getTheme() == darkTheme
                ? Colors.white : Colors.black54,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          height: double.maxFinite,
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                  ),
                  TextField(
                    controller: _titleController,
                    autofocus: false,
                    onChanged: (val) {
                      isEmpty();
                    },
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      counterText: '',
                      isDense: true,
                      filled: true,
                      contentPadding: const EdgeInsets.only(
                          top: 12.0, bottom: 12, left: 10),
                     // errorText:
                      // hateError ? 'Hate speech detected!' : null,
                      border: InputBorder.none,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintText: 'Meeting Topic',
                      fillColor: themeNotifier.getTheme() == darkTheme
                          ? Color(0xFF191919)
                          : Color(0xFFf9f9f9),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  SizedBox(
                    height: 50.0,
                    width: MediaQuery.of(context).size.width * 0.90,
                    child: RaisedButton(
                      disabledColor: themeNotifier.getTheme() == darkTheme
                          ? Color(0xFF242424)
                          : Colors.grey,
                      elevation: 5,
                      disabledElevation: 0,
                      disabledTextColor: themeNotifier.getTheme() == darkTheme
                          ? Colors.grey
                          : Colors.white,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      onPressed: isButtonEnabled
                          ? () async {
                        var connectivityResult = await (Connectivity()
                            .checkConnectivity());
                        if (connectivityResult ==
                            ConnectivityResult.none) {
                          Fluttertoast.showToast(
                              msg: 'No internet connection',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.SNACKBAR,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else {
                          Navigator.pop(context);
                          _hostLiveMeeting(randomNumeric(11), _titleController.text);
                        }
                      }
                          : null,
                      child: Text(
                        "Start",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      color: Color(0xff0184dc)
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text('Once you start the meeting, Just Meet users from all over the world will be able to see and join your meeting',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,),
    ]),
    ),
    ),
    ),
      ),
    );
  }

  _hostLiveMeeting(String id, String topic) async {
    String serverUrl =
    serverText.text?.trim()?.isEmpty ?? "" ? null : serverText.text;

    try {
      Map<FeatureFlag, Object> featureFlags = {
        FeatureFlag.isWelcomePageEnabled: false,
       // featureFlag.resolution = FeatureFlagVideoResolution.HD_RESOLUTION;
        FeatureFlag.isPipEnabled: false,
        FeatureFlag.isAddPeopleEnabled: false,
        FeatureFlag.isInviteEnabled: false,
        FeatureFlag.isCalendarEnabled: false,
      };

      // Here is an example, disabling features for each platform
      if (Platform.isAndroid) {
        featureFlags[FeatureFlag.isCallIntegrationEnabled] = false;
        featureFlags[FeatureFlag.isInviteEnabled] = false;
        featureFlags[FeatureFlag.isToolboxAlwaysVisible] = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
      }

      // Define meetings options here
      var options = JitsiMeetingOptions(
          roomNameOrUrl: id,
          serverUrl: serverUrl,
          subject: topic,
          userDisplayName: widget.name,
          userEmail: widget.email,
          isAudioOnly: false,
          isAudioMuted: true,
          isVideoMuted: true,
          userAvatarUrl: widget.url,
          featureFlags: featureFlags,
        );

      debugPrint("JitsiMeetingOptions: $options");
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        Fluttertoast.showToast(
            msg: 'No Internet Connection!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.SNACKBAR,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        await JitsiMeetWrapper.joinMeeting(
          options: options,
          listener: JitsiMeetingListener(onConferenceWillJoin: (message) {
            Fluttertoast.showToast(
                msg: 'Starting your meeting...',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.SNACKBAR,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
          }, onConferenceJoined: (message) async {
            databaseService.addLive(id, widget.email, widget.name, options.subject);
            Fluttertoast.showToast(
                msg: 'Meeting Started',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.SNACKBAR,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
          }, onConferenceTerminated: (url, error) {
            databaseService.removeLive(id);
            Fluttertoast.showToast(
                msg: 'Meeting Ended By You',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.SNACKBAR,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
            adHelper.showInterstitialAd();
          },
          ),);
      }
    } catch (error) {
      Fluttertoast.showToast(
          msg: "Couldn't Start Your Meeting",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      debugPrint("error: $error");
    }
  }
}
