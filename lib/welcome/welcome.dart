import 'package:flutter/material.dart';
import 'package:buddy/welcome/signup.dart';
import 'login.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'Assets/Pictures/buddyBG.jpg', // Replace with your actual image path
              fit: BoxFit.cover,
            ),
          ),

          // Content Layer
          SafeArea(
            child: Column(
              children: [
                // Welcome Text at the Top
                Padding(
                  padding: const EdgeInsets.only(top: 50), // Adjust spacing
                  child: Center(
                    child: Text(
                      'Welcome to Buddy!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                        color: Colors.black, // Ensure readability
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: Colors.white,
                            offset: Offset(1.5, 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Spacer(), // Pushes buttons to the bottom while keeping text at the top

                // Buttons Section
                Padding(
                  padding: const EdgeInsets.only(bottom: 60, left: 30, right: 30), // Moves buttons up slightly
                  child: Column(
                    children: [
                      // Login Button
                      MaterialButton(
                        minWidth: double.infinity,
                        height: 60,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        },
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Sign Up Button
                      MaterialButton(
                        minWidth: double.infinity,
                        height: 60,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignupPage()),
                          );
                        },
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Text(
                          'Sign up',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
