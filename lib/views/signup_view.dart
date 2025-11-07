import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../widgets/otp_field.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController(),
      child: const _SignUpContent(),
    );
  }
}

class _SignUpContent extends StatefulWidget {
  const _SignUpContent();

  @override
  State<_SignUpContent> createState() => _SignUpContentState();
}

class _SignUpContentState extends State<_SignUpContent> {
  bool showWelcome = false;

  void _createAccount(AuthController controller) {
    if (controller.validateAccount()) {
      setState(() => showWelcome = true);
      Timer(const Duration(seconds: 3), () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AuthController>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // 🎨 خلفية بتدرّج لوني ناعم (أخضر إلى أبيض)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFA8E6CF), // أخضر فاتح
                    Color(0xFFF0FFF4), // أبيض مائل للأخضر
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),

            // 🌫️ طبقة Blur شفافة
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.white.withOpacity(0.1)),
            ),

            // 🧱 المحتوى الرئيسي
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // ✅ اللوجو الدائري + النص
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.green.shade400,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: 3,
                                ),
                              ],
                              image: const DecorationImage(
                                image: AssetImage('assets/takkeh_logo.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "إنشاء حساب تكّة",
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 3,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Expanded(
                      child: Center(
                        child:
                            showWelcome
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.emoji_events,
                                      color: Colors.green,
                                      size: 80,
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      "🎉 مرحباً بك في عائلة تكّة !",
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                )
                                : SingleChildScrollView(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: _buildCurrentStep(
                                      context,
                                      controller,
                                    ),
                                  ),
                                ),
                      ),
                    ),

                    // 🟢 زر "لديك حساب بالفعل؟ تسجيل الدخول"
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, top: 10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "لديك حساب بالفعل؟ ",
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                            ),
                            children: [
                              TextSpan(
                                text: "تسجيل الدخول",
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildCurrentStep(BuildContext context, AuthController controller) {
    if (!controller.otpStep && !controller.accountStep) {
      return Column(
        key: const ValueKey('phone'),
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPhoneField(controller),
          const SizedBox(height: 20),
          _buildButton("إرسال كود التحقق", () => controller.sendOTP(context)),
        ],
      );
    }

    if (controller.otpStep && !controller.accountStep) {
      return Column(
        key: const ValueKey('otp'),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "أدخل الكود المرسل",
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 20),
          Directionality(
            textDirection: TextDirection.ltr,
            child: OTPField(
              enabled: true,
              controllers: controller.otpControllers,
            ),
          ),
          if (controller.otpError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                controller.otpError!,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          const SizedBox(height: 20),
          _buildButton("تأكيد الكود", () => controller.verifyOTP(context)),
        ],
      );
    }

    return Column(
      key: const ValueKey('account'),
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildField(
          "اسم المستخدم",
          controller.usernameCtrl,
          error: controller.usernameError,
        ),
        const SizedBox(height: 15),
        _buildField(
          "كلمة المرور",
          controller.passCtrl,
          obscure: true,
          error: controller.passError,
        ),
        const SizedBox(height: 15),
        _buildField(
          "تأكيد كلمة المرور",
          controller.confirmCtrl,
          obscure: true,
          error: controller.confirmError,
        ),
        const SizedBox(height: 25),
        _buildButton("إنشاء الحساب", () => _createAccount(controller)),
      ],
    );
  }

  /// رقم الجوال: RTL للنصوص، LTR للأرقام، المقدمة على اليسار
  Widget _buildPhoneField(AuthController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12, bottom: 8),
          child: Text(
            "رقم الجوال",
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.green,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // 🔁 المقدمة الآن على اليسار
        Row(
          textDirection: TextDirection.rtl,
          children: [
            // 🟩 حقل الرقم
            Expanded(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: TextField(
                  controller: controller.phoneCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 9,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: "5XXXXXXXX",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 16,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.6),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // 🟩 زر المقدمة (+972 / +970)
            GestureDetector(
              onTap: controller.toggleCountryCode,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade100.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.green.shade300, width: 1),
                ),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.countryCode,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.swap_horiz,
                        size: 16,
                        color: Colors.green.shade700,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // 🟥 رسالة الخطأ
        if (controller.phoneError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 12),
            child: Text(
              controller.phoneError!,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    String? error,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12, bottom: 8),
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.green,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Directionality(
          textDirection: TextDirection.rtl,
          child: TextField(
            controller: controller,
            obscureText: obscure,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.6),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 12),
            child: Text(
              error,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 3,
          shadowColor: Colors.green.shade200,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
