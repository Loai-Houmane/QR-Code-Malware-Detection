import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_code_malw/qr_result.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner',
      debugShowCheckedModeBanner: false,
      // home: QRScanner(),
      home:mm(),
    );
  }
}

class mm extends StatefulWidget {
  const mm({super.key});

  @override
  State<mm> createState() => _mmState();
}

class _mmState extends State<mm> {
  int _pageIndex = 0;
  final List<Widget> _pages= [
    HomePage(),
    HistoryPage(),
    QRScanner(),
    Acount(),
    Settings(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:IndexedStack(
        index:_pageIndex,
        children: _pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.amber.shade900,
        color:Colors.amber.shade900,
        animationDuration: const Duration(milliseconds: 500),
        items: <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.history, size: 30, color: Colors.white),
          Icon(Icons.qr_code_scanner, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
          Icon(Icons.settings, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
    );
  }
}


class HomePage extends StatelessWidget {
  const HomePage ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: Text("Home Page",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),
      ),
    ),
    );
  }
}
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: Text("History of scannes ",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),
      ),
    ),
    );
  }
}
class Acount extends StatelessWidget {
  const Acount({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: Text("Personal Acount Page",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),
      ),
    ),
    );
  }
}
class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: Text("Settings Page",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),
      ),
    ),
    );
  }
}

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  bool isFlashOn = false;
  bool isFrontCamera = false;
  bool isScanCompleted = false;
  MobileScannerController cameraController = MobileScannerController();

  void closeScreen() {
    isScanCompleted = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(25),
        child: Column(
          children: [
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Scan QR Code",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                ),
                // Text(
                //   "Scan QR code for security check.",
                //   style: TextStyle(color: Colors.black54, fontSize: 16),
                // )
              ],
            )),
            SizedBox(
              height: 0,
            ),
            Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    ClipRRect(
                      // color: Colors.amber.shade900,
                      borderRadius: BorderRadius.circular(20.0), 
                      child: MobileScanner(
                        controller: cameraController,
                        allowDuplicates: true,
                        onDetect: (barcode, args) async {
                          if (!isScanCompleted) {
                            isScanCompleted = true;
                            String code = barcode.rawValue ?? "---";
                            
                            

                            
                              
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return ResultPage(
                                    url: code,
                                  );
                                }),
                              ).then((_) => isScanCompleted = false); // Reset isScanCompleted here
                           
                          }
                        },
                      ),
                    ),
                    QRScannerOverlay(
                      overlayColor: Colors.transparent,
                      borderColor: Colors.amber.shade900,
                      borderRadius: 20,
                      borderStrokeWidth: 10,
                      scanAreaWidth: 250,
                      scanAreaHeight: 250,
                    ),
                    //flash light on or off butttom and camera switch button if it on yellow color else white
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0, // Add this line
                      child: Center( // Wrap Row with Center
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Center the icons horizontally
                          children: [
                            //flash light on or off button
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  isFlashOn = !isFlashOn; // Toggle the state
                                  cameraController.toggleTorch(); // Call toggleTorch on the controller
                                });
                                print("Flashlight Toggled: $isFlashOn"); // Debug statement to confirm the method call
                              },
                              icon: Icon(
                                isFlashOn ? Icons.flash_off : Icons.flash_on, // Change the icon based on the state
                                color: isFlashOn ? Colors.amber.shade900 : Colors.white,
                              ),
                            ),
                            SizedBox(width: 20,),
                            //camera switch button
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  isFrontCamera = !isFrontCamera;
                                });
                                cameraController.switchCamera();
                              },
                              icon: Icon(
                                Icons.flip_camera_android,
                                color: isFrontCamera ? Colors.amber.shade900 : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                  
                  

                )),
            
          ],
        ),
      ),
    );
  }
}
