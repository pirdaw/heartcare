import 'package:flutter/material.dart';
import 'check_email_page.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 35),

              // ==========================================
              // TOMBOL KEMBALI
              // ==========================================
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0F0F0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    size: 23,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ==========================================
              // JUDUL
              // ==========================================
              const Text(
                'Forgot Password',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 12),

              // ==========================================
              // DESKRIPSI
              // ==========================================
              const Text(
                'Please enter your email to reset the password',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 35),

              // ==========================================
              // LABEL EMAIL
              // ==========================================
              const Text(
                'Your Email',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 14),

              // ==========================================
              // INPUT EMAIL
              // ==========================================
              SizedBox(
                height: 58,
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'enter your email',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        color: Color(0xFF76AFC7),
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        color: Color(0xFF147C9C),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 27),

              // ==========================================
              // TOMBOL RESET PASSWORD
              // ==========================================
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CheckEmailPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B9AC1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Reset password',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}