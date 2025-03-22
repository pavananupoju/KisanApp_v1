import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisan/components/grid.dart';
import 'package:kisan/pages/disease.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Home Screen"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 16),
              child: SizedBox(
                height: 100,
                child: Text(
                  "Welcome User....",
                  style: GoogleFonts.roboto(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    CategoryCard(
                      title: "Plant Disease",
                      icon: Icons.agriculture,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PlantDiseasePredictor()),
                        );
                      },
                    ),
                    CategoryCard(
                      title: "Plant Disease",
                      icon: Icons.agriculture,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PlantDiseasePredictor()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
