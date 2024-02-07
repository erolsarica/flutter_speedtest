import 'package:flutter/material.dart';
import 'package:flutter_internet_speed_test/flutter_internet_speed_test.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SpeedTestPage extends StatefulWidget {
  const SpeedTestPage({super.key});

  @override
  State<SpeedTestPage> createState() => _SpeedTestPageState();
}

class _SpeedTestPageState extends State<SpeedTestPage> {
  double showProgress = 0.0;
  double _downloadRate = 0.0;
  double _uploadRate = 0.0;
  double _displayRate = 0.0;
  bool isServerInProgress = false;
  bool speedTestStart = false;

  String? _ip;
  String? _isp;
  String? _asn;

  String unitText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Speed Test', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const Text(
              'Progress',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            LinearPercentIndicator(
              percent: showProgress/100.0,
              lineHeight: 20,
              backgroundColor: Colors.white,
              progressColor: Colors.green,
              barRadius: const Radius.circular(7),
              center: Text(
                '${(showProgress * 100).toStringAsFixed(2)}%',
                style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Download Rate',
                        style: TextStyle(
                          color: Colors.white,
                          //fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Upload Rate',
                        style: TextStyle(
                          color: Colors.white,
                          //fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_downloadRate.toStringAsFixed(2)} $unitText',
                        style: const TextStyle(
                          color: Colors.white,
                          //fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_uploadRate.toStringAsFixed(2)} $unitText',
                        style: const TextStyle(
                          color: Colors.white,
                          //fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SfRadialGauge(
              axes: [
                RadialAxis(
                  radiusFactor: 0.85,
                  minorTicksPerInterval: 1,
                  tickOffset: 3,
                  useRangeColorForAxis: true,
                  interval: 4,
                  minimum: 0,
                  maximum: 25,
                  //showLastLabel: true,
                  axisLabelStyle: const GaugeTextStyle(
                    color: Colors.white,
                  ),
                  ranges: [
                    GaugeRange(
                      color: const Color.fromARGB(255, 47, 247, 54),
                      startValue: 0,
                      endValue: 24,
                      startWidth: 5,
                      endWidth: 10,
                    ),
                  ],
                  pointers: <GaugePointer>[
                    NeedlePointer(
                      value: _displayRate,
                      enableAnimation: true,
                      //needleLength: 0.6,
                      needleColor: Colors.white,
                      tailStyle: const TailStyle(
                        color: Colors.white,
                        borderWidth: 0.02,
                        borderColor: Colors.red,
                      ),

                      knobStyle: const KnobStyle(
                        knobRadius: 0.08,
                        sizeUnit: GaugeSizeUnit.factor,
                        borderColor: Colors.white,
                        color: Colors.white,
                        borderWidth: 0.035,
                      ),
                    ),
                  ],
                  annotations: [
                    GaugeAnnotation(
                        widget: Container(
                          child: Text(
                            _displayRate.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        angle: 90,
                        positionFactor: 0.7)
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              isServerInProgress ? 'Server is in progress...' : 'IP: ${_ip ?? '__'} | ASN: ${_asn ?? '__'} | ISP: ${_isp ?? '__'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                speedTest();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Start Test',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  speedTest() {
    final speedTest = FlutterInternetSpeedTest();
    speedTest.startTesting(
      //true(default)
      onStarted: () {
        setState(() {
          speedTestStart = true;
        });
      },
      onCompleted: (TestResult download, TestResult upload) {
        setState(() {
          unitText = download.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
          _downloadRate = download.transferRate;
          showProgress = 100.0;
          _displayRate = _downloadRate;
          
        });
        setState(() {
          unitText = upload.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
          _uploadRate = upload.transferRate;
          showProgress = 100.0;
          _displayRate = _uploadRate;
          speedTestStart = false;
        });
      },
      onProgress: (double percent, TestResult data) {
        setState(() {
         unitText = data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
         if (data.type == TestType.download) {
            _downloadRate = data.transferRate;
            showProgress = percent;
            _displayRate = _downloadRate;
          } else {
            _uploadRate = data.transferRate;
            showProgress = percent;
            _displayRate = _uploadRate;
          }
        });
      },
      onError: (String errorMessage, String speedTestError) {
        print('Error: $errorMessage | $speedTestError');
      },
      onDefaultServerSelectionInProgress: () {
        setState(() {
          isServerInProgress = true;
        });
        //Only when you use useFastApi parameter as true(default)
      },
      onDefaultServerSelectionDone: (Client? client) {
        setState(() {
          isServerInProgress = false;
          _ip = client?.ip;
          _isp = client?.isp;
          _asn = client?.asn;
        });
        //Only when you use useFastApi parameter as true(default)
      },
      onDownloadComplete: (TestResult data) {
        setState(() {
          unitText = data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
          _downloadRate = data.transferRate;
          _displayRate = _downloadRate;        
        });
      },
      onUploadComplete: (TestResult data) {
        setState(() {
          unitText = data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
          _uploadRate = data.transferRate;
          _displayRate = _uploadRate;
        });
      },
      onCancel: () {
        // TODO Request cancelled callback
      },
    );
  }
}
