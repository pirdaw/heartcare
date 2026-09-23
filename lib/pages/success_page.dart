import 'package:flutter/material.dart';
import 'login_page.dart';

class SuccessPage extends StatelessWidget {
  final String title;
  final String message;
  final String subMessage;
  final String buttonText;
  final VoidCallback? onButtonPressed;

  const SuccessPage({
    super.key,
    this.title = 'Successful',
    this.message = 'Password Anda telah berhasil diubah',
    this.subMessage = 'Silakan klik Selesai untuk masuk ke akun Anda.',
    this.buttonText = 'Selesai',
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ==========================================
                // ICON CENTANG
                // ==========================================
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF009FE3),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF4D91D8),
                    size: 36,
                  ),
                ),

                const SizedBox(height: 24),

                // ==========================================
                // SUCCESSFUL / JUDUL
                // ==========================================
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 12),

                // ==========================================
                // KETERANGAN
                // ==========================================
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  subMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 40),

                // ==========================================
                // TOMBOL SELESAI / AKSI
                // ==========================================
                SizedBox(
                  width: 130,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onButtonPressed ??
                        () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B9AC1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
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
      ),
    );
  }
}