import 'package:color_picker/template/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:color_picker/widgets/button_widget.dart';
import 'package:color_picker/widgets/input_widget.dart';
import 'package:color_picker/widgets/notification_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ColorPickerApp extends StatefulWidget {
  const ColorPickerApp({super.key});
  @override
  State<ColorPickerApp> createState() => _ColorPickerAppState();
}

class _ColorPickerAppState extends State<ColorPickerApp> {
  // ------------------------------------------------------------
  //
  //                          VARIABLES
  //
  // ------------------------------------------------------------

  Color currentColor = const Color.fromARGB(255, 82, 177, 255);
  List<Color> colorPalette = [];
  final TextEditingController hexController = TextEditingController();
  final TextEditingController rgbController = TextEditingController();

  Color textColor = Colors.black;
  Color borderColor = Colors.black;
  Color buttonTextColor = Colors.white;
  Color buttonColor = const Color.fromARGB(255, 82, 177, 255);

  int _currentIndex = 0;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ------------------------------------------------------------
  //
  //                          FONCTIONS
  //
  // ------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    // Listeners pour les champs HEX et RGB
    hexController.addListener(() {
      final hex = hexController.text.trim();
      updateColorFromHex(hex);
    });
    rgbController.addListener(() {
      final rgb = rgbController.text.trim();
      updateColorFromRGB(rgb);
    });
  }

  void _navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void changeColor(Color color) {
    setState(() {
      currentColor = color;
      updateTextAndBorderColor(currentColor);
      updateButtonColor(currentColor);
      colorPalette = [];
    });
  }

  Color generateRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  void changeToRandomColor() {
    setState(() {
      currentColor = generateRandomColor();
    });
    rgbController.text =
        '${currentColor.red},${currentColor.green},${currentColor.blue}';
  }

  void resetColor() {
    setState(() {
      currentColor = const Color.fromARGB(255, 82, 177, 255);
    });
    rgbController.text = '';
    hexController.text = '';

    setState(() {
      colorPalette = [];
    });
  }

  void updateColorFromHex(String hex) {
    if (hex.isNotEmpty) {
      try {
        final formattedHex = hex.startsWith('#') ? hex : '#$hex';
        if (formattedHex.length == 7) {
          final color1 =
              int.parse(formattedHex.replaceFirst('#', 'FF'), radix: 16);
          final color = Color(color1);
          changeColor(color);
          rgbController.text = '${color.red},${color.green},${color.blue}';
        }
      } catch (e) {
        // Ignorer les erreurs
      }
    }
  }

  void updateColorFromRGB(String rgb) {
    if (rgb.isNotEmpty) {
      try {
        final values =
            rgb.split(',').map((v) => int.tryParse(v.trim()) ?? 0).toList();
        if (values.length == 3 && values.every((v) => v >= 0 && v <= 255)) {
          final color = Color.fromRGBO(values[0], values[1], values[2], 1);
          changeColor(color);

          final hexColor =
              '#${values[0].toRadixString(16).padLeft(2, '0')}${values[1].toRadixString(16).padLeft(2, '0')}${values[2].toRadixString(16).padLeft(2, '0')}';
          hexController.text = hexColor.toUpperCase();
        }
      } catch (e) {
        // Ignorer les erreurs
      }
    }
  }

  void updateTextAndBorderColor(Color color) {
    final brightness = color.computeLuminance();
    if (brightness > 0.5) {
      textColor = Colors.black;
      borderColor = Colors.black;
    } else {
      textColor = Colors.white;
      borderColor = Colors.white;
    }
  }

  void updateButtonColor(Color color) {
    final brightness = color.computeLuminance();
    if (brightness > 0.5) {
      buttonTextColor = Colors.white;
      buttonColor = color.withOpacity(0.8);
    } else {
      buttonTextColor = Colors.black;
      buttonColor = color.withOpacity(0.8);
    }
  }

  void generateColorPalette(Color baseColor) {
    List<Color> palette = [];

    palette.add(baseColor);

    for (int i = 1; i <= 2; i++) {
      palette.add(Color.fromARGB(
        255,
        (baseColor.red + i * 20).clamp(0, 255),
        (baseColor.green + i * 20).clamp(0, 255),
        (baseColor.blue + i * 20).clamp(0, 255),
      ));
    }

    for (int i = 1; i <= 2; i++) {
      palette.add(Color.fromARGB(
        255,
        (baseColor.red - i * 20).clamp(0, 255),
        (baseColor.green - i * 20).clamp(0, 255),
        (baseColor.blue - i * 20).clamp(0, 255),
      ));
    }

    palette
        .sort((a, b) => b.computeLuminance().compareTo(a.computeLuminance()));

    setState(() {
      colorPalette = palette;
    });
  }

  Future<void> _savePalette() async {
    final user = _auth.currentUser;

    if (user == null) {
      pushNotificationMessage(
        context: context,
        message: 'LOG IN TO REGISTER A PALLET.',
        type: MessageType.error,
      );
      return;
    }

    if (colorPalette.isEmpty) {
      pushNotificationMessage(
        context: context,
        message: 'NO COLOR IN THE PALLET.',
        type: MessageType.error,
      );
      return;
    }

    try {
      await _firestore.collection('palettes').add({
        'userId': user.uid,
        'colors': colorPalette.map((color) => color.value).toList(),
        'name': 'NEW PALLET',
        'createdAt': FieldValue.serverTimestamp(),
      });

      pushNotificationMessage(
        context: context,
        message: 'PALLET SUCCESSFULLY REGISTERED!',
        type: MessageType.success,
      );
    } catch (e) {
      pushNotificationMessage(
        context: context,
        message: 'REGISTRATION ERROR.',
        type: MessageType.error,
      );
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
            backgroundColor: currentColor,
            title: Text(
              'DECONNEXION',
              style: TextStyle(color: textColor),
            ),
            content: Text('Are you sure you want to disconnect?',
                style: TextStyle(color: textColor)),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text('ANNULER', style: TextStyle(color: textColor)),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  button(
                      label: 'LOGOUT',
                      themeColor: currentColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      icon: Icons.no_accounts_rounded),
                ],
              )
            ]);
      },
    );

    if (shouldLogout == true) {
      await _logout();
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      setState(() {});
      pushNotificationMessage(
        // ignore: use_build_context_synchronously
        context: context,
        message: 'DISCONNECTED WITH SUCCESS',
        type: MessageType.success,
      );
    } catch (e) {
      pushNotificationMessage(
        // ignore: use_build_context_synchronously
        context: context,
        message: 'DISCONNECTED FAILED',
        type: MessageType.error,
      );
    }
  }

  @override
  void dispose() {
    hexController.dispose();
    rgbController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  //
  //                        UTILITY WIDGET
  //
  // ------------------------------------------------------------

  // Widget displaying the button used to save the palette if it's not empty
  Widget _saveButtonIfColorpalletteExist() {
    return colorPalette.isNotEmpty
        ? button(
            label: 'SAVE',
            themeColor: currentColor,
            borderColor: borderColor,
            textColor: textColor,
            onPressed: () {
              _savePalette();
            },
            icon: Icons.save_as_rounded)
        : const SizedBox();
  }

  // Widget displaying the button used to create the pallet from a given color
  Widget _createpalletButtonIfColorpalletteNotExist() {
    return colorPalette.isEmpty
        ? button(
            label: 'CREATE PALLET',
            themeColor: currentColor,
            borderColor: borderColor,
            textColor: textColor,
            onPressed: () {
              setState(() {
                generateColorPalette(currentColor);
              });
            },
            icon: Icons.create_rounded)
        : const SizedBox();
  }

  // Widget displaying the user icon in the application bar for logging in and out
  Widget _displayUserIconAppBar() {
    final user = _auth.currentUser;

    if (user == null) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: currentColor,
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: textColor.withOpacity(1),
              blurRadius: 0,
              offset: const Offset(4, 3),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(Icons.person, color: textColor),
          iconSize: 30.0,
          // onPressed: () {
          //   _navigateToPage(LoginPage(
          //     currentColor: currentColor,
          //     borderColor: borderColor,
          //     textColor: textColor,
          //   ));
          // },
          onPressed: () async {
            await _auth.signInAnonymously(); // Connexion rapide pour les tests
            setState(() {});
            pushNotificationMessage(
              context: context,
              message: 'CONNECTED WITH SUCCESS',
              type: MessageType.success,
            );
          },
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: currentColor,
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: textColor.withOpacity(1),
              blurRadius: 0,
              offset: const Offset(4, 3),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(Icons.person, color: textColor),
          iconSize: 30.0,
          onPressed: () {
            _confirmLogout();
          },
        ),
      );
    }
  }

  void _showPaletteDetails(
      BuildContext context, List<Color> colors, String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: currentColor,
          title: Text(name, style: TextStyle(color: textColor)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: colors.length,
                  itemBuilder: (context, index) {
                    final color = colors[index];
                    final hexColor =
                        '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
                    return ListTile(
                      leading: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      title: Text(hexColor, style: TextStyle(color: textColor)),
                    );
                  },
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('CLOSE', style: TextStyle(color: textColor)),
            ),
          ],
        );
      },
    );
  }

  // Widget that displays the second page: the color pallet
  Widget _buildColorPalletContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            input(
              controller: hexController,
              hintText: 'HEX ( #RRGGBB )',
              icon: Icons.color_lens_rounded,
              currentColor: currentColor,
              textColor: textColor,
              borderColor: borderColor,
            ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              _createpalletButtonIfColorpalletteNotExist(),
              const SizedBox(width: 10),
              _saveButtonIfColorpalletteExist()
            ]),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: colorPalette.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisExtent: 70,
                ),
                itemBuilder: (context, index) {
                  final hexColor =
                      '#${colorPalette[index].value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
                  return Container(
                    color: colorPalette[index],
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            hexColor,
                            style: TextStyle(color: textColor),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: hexColor));
                              pushNotificationMessage(
                                context: context,
                                message: '$hexColor COPIED TO CLIPBOARD !',
                                type: MessageType.success,
                              );
                            },
                            icon: const Icon(Icons.copy, size: 18),
                            color: textColor,
                            tooltip: "Copy HEX code",
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget that displays the first/front page: the color picker
  Widget _buildColorPickerContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30.0, 180.0, 30.0, 0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            input(
                controller: hexController,
                hintText: 'HEX ( #RRGGBB )',
                icon: Icons.color_lens_rounded,
                currentColor: currentColor,
                textColor: textColor,
                borderColor: borderColor),
            const SizedBox(height: 20),
            input(
                controller: rgbController,
                hintText: 'RGB ( R,G,B )',
                icon: Icons.format_color_fill_rounded,
                currentColor: currentColor,
                textColor: textColor,
                borderColor: borderColor),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                button(
                    label: 'RANDOM',
                    themeColor: currentColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    onPressed: changeToRandomColor,
                    icon: FontAwesomeIcons.diceFive),
                const SizedBox(width: 10),
                button(
                    label: 'RESET',
                    themeColor: currentColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    onPressed: resetColor,
                    icon: Icons.restore_rounded)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPalletViewer() {
    final user = _auth.currentUser;

    if (user == null) {
      return Center(
        child: Text(
          'PLEASE LOG IN TO VIEW YOUR PALLETS.',
          style: TextStyle(fontSize: 16, color: textColor),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('palettes')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: textColor),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'NO PALLETS SAVED.',
                style: TextStyle(fontSize: 16, color: textColor),
              ),
            );
          }

          final palettes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: palettes.length,
            itemBuilder: (context, index) {
              final paletteData = palettes[index];
              final colors = (paletteData['colors'] as List)
                  .map((colorValue) => Color(colorValue))
                  .toList();
              final paletteName = paletteData['name'] ?? 'Palette ${index + 1}';
              final paletteId = paletteData.id;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: paletteName,
                            style: TextStyle(fontSize: 16, color: textColor),
                            decoration: InputDecoration(
                              hintText: 'PALLET NAME',
                              hintStyle: TextStyle(color: textColor),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: textColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: borderColor),
                              ),
                            ),
                            onFieldSubmitted: (newName) {
                              paletteData.reference
                                  .update({'name': newName.trim()});
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.delete, color: textColor),
                          onPressed: () async {
                            await paletteData.reference.delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('PALLET SUCCESSFULLY DELETED.')),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.visibility, color: textColor),
                          onPressed: () {
                            _showPaletteDetails(context, colors, paletteName);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      height: 70,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              colors.length <= 5 ? colors.length : 5,
                          crossAxisSpacing: 8.0,
                        ),
                        itemCount: colors.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, colorIndex) {
                          return Container(
                            decoration: BoxDecoration(
                              color: colors[colorIndex],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Main/Returned widget for building the color picker application
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: currentColor,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'COLOR.PICK',
                style: TextStyle(fontSize: 30, color: textColor),
              ),
              _displayUserIconAppBar()
            ],
          ),
        ),
      ),
      body: Container(
        color: currentColor,
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildColorPickerContent(),
            _buildColorPalletContent(),
            _buildPalletViewer()
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: textColor.withOpacity(0.8),
              blurRadius: 2.0,
              offset: const Offset(0, -0.5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor:
              currentColor,
          currentIndex: _currentIndex,
          selectedItemColor:
              textColor,
          unselectedItemColor: textColor.withOpacity(
              0.6),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.colorize_rounded, color: textColor),
              label: 'PICKER',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.color_lens, color: textColor),
              label: 'COLOR PALLET',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.collections_rounded, color: textColor),
              label: 'COLLECTION',
            ),
          ],
        ),
      ),
    );
  }
}
