// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:user_messaging_platform/user_messaging_platform.dart';

import 'theme.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme(),
      darkTheme: darkTheme(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Using a field to access the plugin makes access less verbose and allows
  // replacing it with a mock for testing.
  final _ump = UserMessagingPlatform.instance;

  // Only applicable to iOS.
  TrackingAuthorizationStatus? _trackingAuthorizationStatus;

  // The latest consent info.
  ConsentInformation? _consentInformation;

  // Settings for ConsentRequestParameters
  bool _tagAsUnderAgeOfConsent = false;
  bool _debugSettings = false;
  String? _testDeviceId;
  DebugGeography _debugGeography = DebugGeography.disabled;

  @override
  void initState() {
    // Load the current `TrackingAuthorizationStatus`.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      _loadTrackingAuthorizationStatus();
    }

    // Load the latest `ConsentInformation`. This will always work but does
    // not request the latest info from the UMP backend.
    _loadConsentInfo();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // UMP
              Text(
                'User Messaging Platform',
                style: Theme.of(context).textTheme.headline5,
              ),
              SizedBox(height: 16),
              if (_consentInformation == null)
                LinearProgressIndicator()
              else
                Text(_consentInformation.toString()),
              SizedBox(height: 16),
              CheckboxListTile(
                title: Text('Tag as under age of consent'),
                value: _tagAsUnderAgeOfConsent,
                onChanged: (value) {
                  setState(() {
                    _tagAsUnderAgeOfConsent = value!;
                  });
                },
              ),
              _buildDebugSettings(context),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text('Request consent info update'),
                onPressed: _requestConsentInfoUpdate,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text('Reset consent info'),
                onPressed: _resetConsentInfo,
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
                  'App Tracking Transparency',
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

  Future<void> _loadTrackingAuthorizationStatus() {
    return _ump.getTrackingAuthorizationStatus().then((status) {
      setState(() {
        _trackingAuthorizationStatus = status;
      });
    });
  }

  Future<void> _requestATTPermission() {
    return _ump.requestTrackingAuthorization().then((status) {
      setState(() {
        _trackingAuthorizationStatus = status;
      });
    });
  }

  Future<void> _loadConsentInfo() {
    return _ump.getConsentInfo().then((info) {
      setState(() {
        _consentInformation = info;
      });
    });
  }

  Future<void> _requestConsentInfoUpdate() {
    return _ump
        .requestConsentInfoUpdate(_buildConsentRequestParameters())
        .then((info) {
      setState(() {
        _consentInformation = info;
      });
    });
  }

  Future<void> _resetConsentInfo() async {
    await _ump.resetConsentInfo();
    await _loadConsentInfo();
  }

  Future<void> _showConsentForm() {
    return _ump.showConsentForm().then((info) {
      setState(() {
        _consentInformation = info;
      });
    });
  }

  ConsentRequestParameters _buildConsentRequestParameters() {
    final parameters = ConsentRequestParameters(
      tagForUnderAgeOfConsent: _tagAsUnderAgeOfConsent,
      debugSettings: _debugSettings
          ? ConsentDebugSettings(
              geography: _debugGeography,
              testDeviceIds: _testDeviceId == null ? null : [_testDeviceId!],
            )
          : null,
    );
    return parameters;
  }

  Widget _buildDebugSettings(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CheckboxListTile(
          title: Text('Debug Settings'),
          value: _debugSettings,
          onChanged: (debugSettings) {
            setState(() {
              _debugSettings = debugSettings!;
            });
          },
        ),
        if (_debugSettings) ...[
          TextFormField(
            initialValue: _testDeviceId,
            onChanged: (testDeviceId) {
              _testDeviceId = testDeviceId.trim();
            },
            decoration: InputDecoration(
              filled: true,
              labelText: 'Test Device Id',
            ),
          ),
          ListTile(
            title: Text('Geography'),
            trailing: DropdownButton<DebugGeography>(
              value: _debugGeography,
              onChanged: (debugGeography) {
                setState(() {
                  _debugGeography = debugGeography!;
                });
              },
              items: [
                DropdownMenuItem(
                  child: Text('Disabled'),
                  value: DebugGeography.disabled,
                ),
                DropdownMenuItem(
                  child: Text('Not EEA'),
                  value: DebugGeography.notEEA,
                ),
                DropdownMenuItem(
                  child: Text('EEA'),
                  value: DebugGeography.EEA,
                ),
              ],
            ),
          )
        ]
      ],
    );
  }
}
