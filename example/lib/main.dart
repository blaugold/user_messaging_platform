// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:user_messaging_platform/user_messaging_platform.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _ump = UserMessagingPlatform.instance;

  TrackingAuthorizationStatus _trackingAuthorizationStatus;

  ConsentInformation _consentInformation;

  @override
  void initState() {
    _ump.getTrackingAuthorizationStatus().then((status) {
      setState(() {
        _trackingAuthorizationStatus = status;
      });
    });

    _ump.getConsentInfo().then((info) {
      setState(() {
        _consentInformation = info;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('user_messaging_platform example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'User Meassaging Platform',
                style: Theme.of(context).textTheme.headline5,
              ),
              SizedBox(height: 16),
              if (_consentInformation == null)
                LinearProgressIndicator()
              else
                Text(_consentInformation.toString()),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text('Request consent info update'),
                onPressed: _requestConsentInfoUpdate,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text('Show consent form'),
                onPressed: _showConsentForm,
              ),

              // ATT
              if (defaultTargetPlatform == TargetPlatform.iOS) ...[
                SizedBox(height: 32),
                Text(
                  'App Tracking Trancparency',
                  style: Theme.of(context).textTheme.headline5,
                ),
                SizedBox(height: 16),
                if (_trackingAuthorizationStatus == null)
                  LinearProgressIndicator()
                else
                  Text('$_trackingAuthorizationStatus'),
                SizedBox(height: 16),
                ElevatedButton(
                  child: Text('Request ATT permission'),
                  onPressed: _requestATTPermission,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _requestATTPermission() {
    _ump.requestTrackingAuthorization().then((status) {
      setState(() {
        _trackingAuthorizationStatus = status;
      });
    });
  }

  void _requestConsentInfoUpdate() {
    _ump.requestConsentInfoUpdate().then((info) {
      setState(() {
        _consentInformation = info;
      });
    });
  }

  void _showConsentForm() {
    _ump.showConsentForm().then((info) {
      setState(() {
        _consentInformation = info;
      });
    });
  }
}
