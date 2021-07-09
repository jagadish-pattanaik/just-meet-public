import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jagu_meet/firebase/ads/admobAds.dart';
import 'package:jagu_meet/firebase/databases/usersCloudDb.dart';
import 'package:jagu_meet/widgets/cupertinoSwitchListTile.dart';
import 'package:jagu_meet/widgets/dialogs.dart';
import 'package:date_time_picker/date_time_picker.dart';
import '../../../theme/theme.dart';
import '../../../theme/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jagu_meet/classes/focusNode.dart';

class NoteScreen extends StatefulWidget {
  final uid;
  final email;
  final id;
  final meetName;
  final date;
  final from;
  final to;
  final ch;
  final live;
  final record;
  final raise;
  final yt;
  final repeat;
  final kick;
  NoteScreen(this.uid,
  this.email,
  this.id,
      this.meetName,
  this.date,
  this.from,
  this.to,
      this.repeat,
  this.ch,
  this.live,
  this.record,
  this.raise,
  this.yt,
  this.kick);

  @override
  State<StatefulWidget> createState() => new _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  DatabaseService databaseService = new DatabaseService();
  AdHelper adHelper = new AdHelper();

  TextEditingController _titleController;
  TextEditingController _descriptionController;
  TextEditingController _dateController;
  TextEditingController _fromController;
  TextEditingController _toController;

  var chatEnabled;
  var liveEnabled;
  var recordEnabled;
  var raiseEnabled;
  var shareYtEnabled;
  var kickOutEnabled;

  var repeat;

  @override
  void initState() {
    super.initState();
    _titleController = new TextEditingController(text: widget.meetName);
    _descriptionController = new TextEditingController(
      text: widget.id,
    );
    _dateController = new TextEditingController(text: widget.date.toString());
    _fromController = new TextEditingController(text: widget.from);
    _toController = new TextEditingController(text: widget.to);
    repeat = widget.repeat;
    chatEnabled = widget.ch;
    liveEnabled = widget.live;
    recordEnabled = widget.record;
    raiseEnabled = widget.raise;
    shareYtEnabled = widget.yt;
    kickOutEnabled = widget.kick;
    adHelper.interstitialAdload();
    checkExists();
    isEmpty();
  }

  bool _dateError = false;
  bool _fromError = false;
  bool _toError = false;

  bool hateError = false;
  List<String> hateSpeech = [
    'Bitch',
    'Fuck',
    'Anal',
    'Fuck',
    'sex',
    'Vaginal',
    'Piss',
    'Rascal',
    'Bastard',
    'Xxx',
    'Porn',
    'Terrorism',
    'Idiot',
    'F*ck',
    'Vagina',
    'F**k',
    'Shit',
    'fucker',
    'Chudai',
    'Dick',
    'Asshole',
    'asshole',
    '****',
    '***',
    'Madarchod',
    'Behenchod',
    'Maa ki',
    'Maaki',
    'Maki',
    'Lund',
    'Chut',
    'Chutad',
    'Bhosdike',
    'Bsdk',
    'Betichod',
    'Chutiya',
    'Harami',
    'chut',
    'Haramkhor'];

  hateDetect(final TextEditingController controller) {
    for (var i = 0; i < hateSpeech.length; i++) {
      if (controller.text.contains(hateSpeech[i])) {
        setState(() {
          hateError = true;
        });
      } else if (controller.text.toLowerCase().contains(hateSpeech[i])) {
        setState(() {
          hateError = true;
        });
      } else if (controller.text.toUpperCase().contains(hateSpeech[i])) {
        setState(() {
          hateError = true;
        });
      } else if (controller.text.isEmpty) {
        setState(() {
          hateError = false;
        });
      }else if (!controller.text.contains(hateSpeech[i])) {
        setState(() {
          hateError = false;
        });
      } else if (!controller.text.toLowerCase().contains(hateSpeech[i])) {
        setState(() {
          hateError = false;
        });
      } else if (!controller.text.toUpperCase().contains(hateSpeech[i])) {
        setState(() {
          hateError = false;
        });
      }
    }
  }

  void check() {
    setState(() {
      _dateController.text.isNotEmpty ? _dateError = false : _dateError = true;
    });

    setState(() {
      _fromController.text.isNotEmpty ? _fromError = false : _fromError = true;
    });

    setState(() {
      _toController.text.isNotEmpty ? _toError = false : _toError = true;
    });
  }

  bool isButtonEnabled;
  isEmpty() {
    if ((_descriptionController.text.length >= 10) &&
        (_titleController.text != "") &&
        (_dateController.text != "") &&
        (_fromController.text != "") &&
        (_toController.text != "")) {
      setState(() {
        isButtonEnabled = true;
      });
    } else {
      setState(() {
        isButtonEnabled = false;
      });
    }
  }

  bool exists = false;
  checkExists() async {
    try {
      await FirebaseFirestore.instance.doc("Users/${widget.uid}/Scheduled/${widget.id}").get().then((doc) {
        if (doc.exists) {
          setState(() {
            exists = true;
          });
        } else {
          setState(() {
            exists = false;
          });
        }});

    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return Theme(
      data: themeNotifier.getTheme(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.clear,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          iconTheme: IconThemeData(color: themeNotifier.getTheme() == darkTheme
              ? Colors.white : Colors.black54),
          backgroundColor: themeNotifier.getTheme() == darkTheme
              ? Color(0xff0d0d0d)
              : Color(0xffffffff),
          elevation: 0,
          bottom: PreferredSize(
              child: Divider(
                  height: 1,
                  color: themeNotifier.getTheme() == darkTheme
                      ?  Color(0xFF303030) : Colors.black12
              ),
              preferredSize: Size(double.infinity, 0.0)),
          title: Text(
    exists == false ? 'Schedule a Meeting' : 'Edit Meeting',
            style: TextStyle(
              color: themeNotifier.getTheme() == darkTheme
                  ? Colors.white : Colors.black54,
            ),
          ),
          actions: [
            IconButton(
              icon: exists
                  ? Icon(
                      Icons.edit_outlined,
                      color:
                          isButtonEnabled ? themeNotifier.getTheme() == darkTheme
                              ? Colors.white : Colors.black54 : Colors.transparent,
                    )
                  : Icon(
                      Icons.add,
                      color:
                          isButtonEnabled ? themeNotifier.getTheme() == darkTheme
                              ? Colors.white : Colors.black54 : Colors.transparent,
                    ),
              onPressed: isButtonEnabled
                  ? () {
                      check();
                      if (exists == true) {
                        if (_descriptionController.text.length >= 10) {
                          if (_titleController.text.isNotEmpty) {
                            if (_dateController.text.isNotEmpty) {
                              if (_fromController.text.isNotEmpty) {
                                if (_toController.text.isNotEmpty) {
                                  databaseService.updateScheduledHosted(widget.uid, _descriptionController.text, _titleController.text, _dateController.text, _fromController.text, _toController.text
                                      , repeat, chatEnabled, liveEnabled, recordEnabled, raiseEnabled, shareYtEnabled, kickOutEnabled, widget.email, false)
                                      .then((_) {
                                    Navigator.pop(context);
                                  });
                                  Fluttertoast.showToast(
                                      msg: 'Meeting updated',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.SNACKBAR,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                  adHelper.showInterstitialAd();
                                }
                              }
                            }
                          }
                        }
                      } else {
                        check();
                        if (_descriptionController.text.length >= 10) {
                          if (_titleController.text.isNotEmpty) {
                            if (_dateController.text.isNotEmpty) {
                              if (_fromController.text.isNotEmpty) {
                                if (_toController.text.isNotEmpty) {
                                  databaseService.addScheduledHosted(false, widget.uid, widget.email, _descriptionController.text, _titleController.text, _dateController.text, _fromController.text, _toController.text, repeat, chatEnabled, liveEnabled, recordEnabled, raiseEnabled, shareYtEnabled, kickOutEnabled)
                                      .then((_) {
                                    Navigator.pop(context);
                                  });
                                  Fluttertoast.showToast(
                                      msg: 'Meeting Scheduled',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.SNACKBAR,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                  adHelper.showInterstitialAd();
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  : null,
            ),
          ],
        ),
        body: SafeArea(
          child: Container(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      controller: _descriptionController,
                      enableInteractiveSelection: false,
                      focusNode: AlwaysDisabledFocusNode(),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: '',
                        isDense: true,
                        filled: true,
                        contentPadding: const EdgeInsets.only(
                            top: 12.0, bottom: 12, left: 10),
                        border: InputBorder.none,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
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
                        hateDetect(_titleController);
                        isEmpty();
                      },
                textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: '',
                        isDense: true,
                        filled: true,
                        contentPadding: const EdgeInsets.only(
                            top: 12.0, bottom: 12, left: 10),
                        errorText:
                            hateError ? 'Hate speech detected!' : null,
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
                    height: 10,
                  ),
              Divider(
                height: 1,
                color: themeNotifier.getTheme() == darkTheme
                    ? Color(0xFF303030)
                    : Colors.black12,
              ),
              DateTimePicker(
                      controller: _dateController,
                      type: DateTimePickerType.date,
                      initialDatePickerMode: DatePickerMode.day,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2022),
                      calendarTitle: 'Meeting Date',
                textAlign: TextAlign.center,
                      onChanged: (value) {
                        isEmpty();
                        setState(() {
                          _dateController.text = value;
                        });
                      },
                      onSaved: (value) {
                        setState(() {
                          _dateController.text = value;
                        });
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        contentPadding: const EdgeInsets.only(
                            top: 12.0, bottom: 12, left: 10),
                        errorText:
                            _dateError ? 'Meeting Date is mandatory' : null,
                        border: InputBorder.none,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
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
                    height: 10,
                  ),Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                  ),
                  ListTile(
                    title: Text(
                      "Repeat",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    tileColor: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF191919)
                        : Color(0xFFf9f9f9),
                    onTap: () => showActionSheet(),
                    subtitle: Text(repeat, overflow: TextOverflow.ellipsis,),
                    dense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                    trailing: IconButton(
                      icon: Icon(
                          Icons.keyboard_arrow_down,
                          size: 20,
                        ),
                      onPressed: () => showActionSheet(),
                  ),
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      'Meeting Time',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: DateTimePicker(
                              controller: _fromController,
                              type: DateTimePickerType.time,
                              calendarTitle: 'From',
                              textAlign: TextAlign.center,
                              dateMask: 'hh:mm a',
                              use24HourFormat: false,
                              onChanged: (value) {
                                isEmpty();
                                setState(() {
                                  _fromController.text = value;
                                });
                              },
                              onSaved: (value) {
                                setState(() {
                                  _fromController.text = value;
                                });
                              },
                              decoration: InputDecoration(
                                isDense: true,
                                filled: true,
                                contentPadding: const EdgeInsets.only(
                                    top: 12.0, bottom: 12, left: 10),
                                errorText: _fromError
                                    ? 'Meeting Time is mandatory'
                                    : null,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: themeNotifier.getTheme() == darkTheme
                                          ? Color(0xFF303030)
                                          : Colors.black12,
                                      width: 1.0),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(10.0),
                                  ),
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                hintText: 'From',
                                fillColor: themeNotifier.getTheme() == darkTheme
                                    ? Color(0xFF191919)
                                    : Color(0xFFf9f9f9),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: DateTimePicker(
                              controller: _toController,
                              type: DateTimePickerType.time,
                              calendarTitle: 'To',
                              dateMask: 'hh:mm a',
                              textAlign: TextAlign.center,
                              use24HourFormat: false,
                              onChanged: (value) {
                                isEmpty();
                                setState(() {
                                  _toController.text = value;
                                });
                              },
                              onSaved: (value) {
                                setState(() {
                                  _toController.text = value;
                                });
                              },
                              decoration: InputDecoration(
                                isDense: true,
                                filled: true,
                                contentPadding: const EdgeInsets.only(
                                    top: 12.0, bottom: 12, left: 10),
                                errorText: _toError
                                    ? 'Meeting Time is mandatory'
                                    : null,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: themeNotifier.getTheme() == darkTheme
                                          ? Color(0xFF303030)
                                          : Colors.black12,
                                      width: 1.0),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(10.0),
                                  ),
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                hintText: 'To',
                                fillColor: themeNotifier.getTheme() == darkTheme
                                    ? Color(0xFF191919)
                                    : Color(0xFFf9f9f9),
                              ),
                            ),
                          ),
                        ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 5,
                    ),
                    child: Text(
                      'Meeting Settings',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                  ),
                  CupertinoSwitchListTile(
                    title: Text(
                      "Chat",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    dense: true,
                    subtitle: Text('Allow participants to chat in meeting', overflow: TextOverflow.ellipsis,),
                    value: chatEnabled,
                    onChanged: onChatChanged,
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                    indent: 15,
                    endIndent: 0,
                  ),
                  CupertinoSwitchListTile(
                    title: Text(
                      "Raise Hand",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    dense: true,
                    subtitle: Text('Allow participants to raise hand', overflow: TextOverflow.ellipsis,),
                    value: raiseEnabled,
                    onChanged: onRaiseChanged,
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                    indent: 15,
                    endIndent: 0,
                  ),
                  CupertinoSwitchListTile(
                    title: Text(
                      "Share YouTube Video",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                        'Allow participants to share YouTube video in meeting', overflow: TextOverflow.ellipsis,),
                    dense: true,
                    value: shareYtEnabled,
                    onChanged: onYtChanged,
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                    indent: 15,
                    endIndent: 0,
                  ),
                  CupertinoSwitchListTile(
                    title: Text(
                      "Record Meeting",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    dense: true,
                    subtitle: Text('Allow Participants to record meeting', overflow: TextOverflow.ellipsis,),
                    value: recordEnabled,
                    onChanged: onRecordChanged,
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                    indent: 15,
                    endIndent: 0,
                  ),
                  CupertinoSwitchListTile(
                    title: Text(
                      "Live streaming",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text('Allow participants to live stream meeting', overflow: TextOverflow.ellipsis,),
                    dense: true,
                    value: liveEnabled,
                    onChanged: onLiveChanged,
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                    indent: 15,
                    endIndent: 0,
                  ),
                  CupertinoSwitchListTile(
                    title: Text(
                      "Kick Out",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                        'Allow participants to kick ou each other in meeting', overflow: TextOverflow.ellipsis,),
                    dense: true,
                    value: kickOutEnabled,
                    onChanged: onKickChanged,
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  showActionSheet() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
          actions: <Widget>[
      Container(
      color:themeNotifier.getTheme() == darkTheme
          ? Color(0xFF242424)
          : Colors.white,
        child: CupertinoActionSheetAction(
              child: Text('Daily',
                style: TextStyle(color: themeNotifier.getTheme() == darkTheme
                    ? Colors.white
                    : Colors.blue,),),
              isDefaultAction: true,
              onPressed: () {
                setState(() {
                  repeat = 'Daily';
                });
                Navigator.pop(context);
              },
            ),
      ),
    Container(
    color:themeNotifier.getTheme() == darkTheme
    ? Color(0xFF242424)
        : Colors.white,
    child: CupertinoActionSheetAction(
              child: Text('Weekly',
                style: TextStyle(color: themeNotifier.getTheme() == darkTheme
                    ? Colors.white
                    : Colors.blue,),),
              isDefaultAction: true,
              onPressed: () {
                setState(() {
                  repeat = 'Weekly';
                });
                Navigator.pop(context);
              },
            ),
    ),
    Container(
    color:themeNotifier.getTheme() == darkTheme
    ? Color(0xFF242424)
        : Colors.white,
    child: CupertinoActionSheetAction(
              child: Text('Monthly',
                style: TextStyle(color: themeNotifier.getTheme() == darkTheme
                    ? Colors.white
                    : Colors.blue,),),
              isDefaultAction: true,
              onPressed: () {
                setState(() {
                  repeat = 'Monthly';
                });
                Navigator.pop(context);
              },
            ),
    ),
    Container(
    color:themeNotifier.getTheme() == darkTheme
    ? Color(0xFF242424)
        : Colors.white,
    child: CupertinoActionSheetAction(
              child: Text('Never',
                style: TextStyle(color: themeNotifier.getTheme() == darkTheme
                    ? Colors.white
                    : Colors.blue,),),
              isDefaultAction: true,
              onPressed: () {
                setState(() {
                  repeat = 'Never';
                });
                Navigator.pop(context);
              },
            )
    ),
          ],
          cancelButton: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color:themeNotifier.getTheme() == darkTheme
                    ? Color(0xFF242424)
                    : Colors.white,
              ),
              child: CupertinoActionSheetAction(
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold),),
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      ),
    );
  }

  onChatChanged(bool value) {
    setState(() {
      chatEnabled = value;
    });
  }

  onYtChanged(bool value) {
    setState(() {
      shareYtEnabled = value;
    });
  }

  onKickChanged(bool value) async {
    if (kickOutEnabled == false) {
      final action = await Dialogs.yesAbortDialog(
          context,
          'Not Recommended',
          'Allowing participants to kick out each other in meeting is not recommended by Just Meet. Do you still want to allow?',
          'Allow',
          'No');
      if (action == DialogAction.yes) {
        setState(() {
          kickOutEnabled = true;
        });
      }
      if (action == DialogAction.abort) {}
    } else {
      setState(() {
        kickOutEnabled = false;
      });
    }
  }

  onLiveChanged(bool value) async {
    if (liveEnabled == false) {
      final action = await Dialogs.yesAbortDialog(
          context,
          'Not Recommended',
          'Allowing participants to live stream meeting is not recommended by Just Meet. Do you still want to allow?',
          'Allow',
          'No');
      if (action == DialogAction.yes) {
        setState(() {
          liveEnabled = true;
        });
      }
      if (action == DialogAction.abort) {}
    } else {
      setState(() {
        liveEnabled = false;
      });
    }
  }

  onRecordChanged(bool value) async {
    if (recordEnabled == false) {
      final action = await Dialogs.yesAbortDialog(
          context,
          'Not Recommended',
          'Allowing participants to record meeting is not recommended by Just Meet. Do you still want to allow?',
          'Allow',
          'No');
      if (action == DialogAction.yes) {
        setState(() {
          recordEnabled = true;
        });
      }
      if (action == DialogAction.abort) {}
    } else {
      setState(() {
        recordEnabled = false;
      });
    }
  }

  onRaiseChanged(bool value) {
    setState(() {
      raiseEnabled = value;
    });
  }
}
