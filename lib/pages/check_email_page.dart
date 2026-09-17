import 'package:flutter/material.dart';
import 'password_reset_page.dart';

class CheckEmailPage extends StatefulWidget {
  const CheckEmailPage({super.key});

  @override
  State<CheckEmailPage> createState() => _CheckEmailPageState();
}

class _CheckEmailPageState extends State<CheckEmailPage> {
  final List<TextEditingController> _controllers =
      List.generate(5, (index) => TextEditingController());

  final List<FocusNode> _focusNodes =
      List.generate(5, (index) => FocusNode());

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

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
                'Check your email',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 12),

              // ==========================================
              // KETERANGAN
              // ==========================================
              const Text(
                'We have sent a reset link\n'
                'to ciskaaa@gmail.com\n'
                'Enter the 5-digit code included in the email.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
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
              // EMAIL
              // ==========================================
              SizedBox(
                height: 58,
                child: TextField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: 'ciskaaa@gmail.com',
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
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
                  ),
                ),
              ),

              const SizedBox(height: 27),

              // ==========================================
              // OTP 5 DIGIT
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  5,
                  (index) {
                    return SizedBox(
                      width: 52,
                      height: 58,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7),
                            borderSide: const BorderSide(
                              color: Color(0xFF70B9FF),
                              width: 1.2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7),
                            borderSide: const BorderSide(
                              color: Color(0xFF0B9AC1),
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 4) {
                            _focusNodes[index + 1].requestFocus();
                          }
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // ==========================================
              // TOMBOL VERIFIKASI
              // ==========================================
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PasswordResetPage(),
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
                    'Verifikasi kode',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ==========================================
              // KIRIM ULANG EMAIL
              // ==========================================
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                    children: [
                      TextSpan(
                        text: 'Belum menerima email? ',
                      ),
                      TextSpan(
                        text: 'Kirim ulang email',
                        style: TextStyle(
                          color: Color(0xFF0077CC),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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