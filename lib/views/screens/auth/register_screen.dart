import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../../../models/user.dart';
import '../../../controllers/register_controller.dart';
import '../../widgets/modern_loading.dart'; // Ensure this exists or use CircularProgressIndicator if not

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _registerController = RegisterController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _acceptTerms = false;

  // Gender and birthdate fields
  String? _selectedGender;
  String? _selectedRole;
  DateTime? _selectedBirthdate;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // UI Helper Methods
  Future<void> _selectBirthdate() async {
    // Default date logic if none selected
    final DateTime initialDate =
        _selectedBirthdate ??
        DateTime.now().subtract(
          const Duration(days: 365 * 10),
        ); // Default ~10 years old
    DateTime tempPickedDate = initialDate;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext builder) {
        return Container(
          height: 320,
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              // Header Sheet
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Tanggal Lahir',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedBirthdate = tempPickedDate;
                        });
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        'Selesai',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF3F88EB),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Cupertino Picker
              Expanded(
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF1E293B),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: initialDate,
                    minimumDate: DateTime(1900),
                    maximumDate: DateTime.now(),
                    onDateTimeChanged: (DateTime newDate) {
                      tempPickedDate = newDate;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Dialog Helpers
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ModernLoading(color: Color(0xFF3F88EB)),
                const SizedBox(height: 20),
                Text(
                  'Sedang memproses...',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _hideLoadingDialog() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _showSuccessDialog(String title, String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: title,
      desc: message,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF181818),
      ),
      descTextStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: const Color(0xFF64748B),
      ),
      btnOkColor: const Color(0xFF3F88EB),
      btnOkText: 'Login Sekarang',
      btnOkOnPress: () {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      },
    ).show();
  }

  void _showWarningDialog(String title, String message, VoidCallback onOk) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.rightSlide,
      title: title,
      desc: message,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF181818),
      ),
      descTextStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: const Color(0xFF64748B),
      ),
      btnOkColor: Colors.orange,
      btnOkText: 'OK',
      btnOkOnPress: onOk,
    ).show();
  }

  void _showErrorDialog(String title, String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: title,
      desc: message,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF181818),
      ),
      descTextStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: const Color(0xFF64748B),
      ),
      btnOkColor: Colors.red,
      btnOkText: 'OK',
      btnOkOnPress: () {},
    ).show();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      _showErrorDialog(
        'Persetujuan Diperlukan',
        'Anda harus menyetujui syarat dan ketentuan.',
      );
      return;
    }

    if (_selectedRole == null) {
      _showErrorDialog('Data Belum Lengkap', 'Silakan pilih peran Anda.');
      return;
    }

    if (_selectedGender == null) {
      _showErrorDialog(
        'Data Belum Lengkap',
        'Silakan pilih jenis kelamin Anda.',
      );
      return;
    }

    if (_selectedBirthdate == null) {
      _showErrorDialog(
        'Data Belum Lengkap',
        'Silakan pilih tanggal lahir Anda.',
      );
      return;
    }

    // Create user model
    final user = User(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      gender: _selectedGender!,
      birthdate: _selectedBirthdate!,
      acceptTerms: _acceptTerms,
      role: _selectedRole!,
    );

    setState(() {
      _isLoading = true;
    });
    _showLoadingDialog();

    try {
      // simulate network delay for better UX feel
      await Future.delayed(const Duration(milliseconds: 1500));

      final result = await _registerController.register(
        user,
        _confirmPasswordController.text,
      );

      _hideLoadingDialog();

      if (mounted) {
        if (result.success) {
          switch (result.type) {
            case RegisterResultType.success:
              _showSuccessDialog('Registrasi Berhasil!', result.message);
              break;
            case RegisterResultType.partialSuccess:
              _showWarningDialog(
                'Registrasi Berhasil dengan Catatan',
                result.message,
                () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              );
              break;
            default:
              _showSuccessDialog('Registrasi Berhasil!', result.message);
          }
        } else {
          _showErrorDialog(
            result.type == RegisterResultType.validationError
                ? 'Data Tidak Valid'
                : 'Registrasi Gagal',
            result.message,
          );
        }
      }
    } catch (e) {
      _hideLoadingDialog();
      if (mounted) {
        _showErrorDialog('Terjadi Kesalahan', 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    bool isPassword = false,
    bool? obscureText,
    VoidCallback? onVisibilityToggle,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.raleway(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText ?? false,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: const Color(0xFF3F88EB)),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      (obscureText ?? false)
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey[500],
                    ),
                    onPressed: onVisibilityToggle,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF3F88EB),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildRoleCard(
    String title,
    String value,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = _selectedRole == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFEFF6FF)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF3F88EB) : Colors.transparent,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF3F88EB).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3F88EB) : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (!isSelected)
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
                      ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isSelected
                      ? const Color(0xFF1E293B)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption(String label, String value, IconData icon) {
    final isSelected = _selectedGender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGender = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF3F88EB)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF3F88EB)
                  : Colors.transparent, // Removed border for unselected
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Curved Header Background (Matching Login)
            Stack(
              children: [
                ClipPath(
                  clipper: HeaderClipper(),
                  child: Container(
                    height: 240, // Slightly shorter than login
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4A90E2), Color(0xFF8E2DE2)],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'Buat Akun Baru',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Bergabunglah bersama kami',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Form Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Transform.translate(
                offset: const Offset(0, -30),
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Role Selection
                          Text(
                            'Pilih Peran',
                            style: GoogleFonts.raleway(
                              color: const Color(0xFF1E293B),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildRoleCard(
                                'Orang Tua',
                                'parent',
                                Icons.family_restroom,
                                'Pantau & lindungi',
                              ),
                              const SizedBox(width: 16),
                              _buildRoleCard(
                                'Anak',
                                'child',
                                Icons.child_care,
                                'Aman berselancar',
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 2. Name
                          _buildTextField(
                            label: 'Nama Lengkap',
                            controller: _nameController,
                            icon: Icons.person_outline,
                            hint: 'Jhon Doe',
                            validator: (v) =>
                                v!.isEmpty ? 'Nama wajib diisi' : null,
                          ),
                          const SizedBox(height: 20),

                          // 3. Email
                          _buildTextField(
                            label: 'Email',
                            controller: _emailController,
                            icon: Icons.email_outlined,
                            hint: 'user@example.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Email wajib diisi';
                              }
                              if (!v.contains('@')) return 'Email tidak valid';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // 4. Gender
                          Text(
                            'Jenis Kelamin',
                            style: GoogleFonts.raleway(
                              color: const Color(0xFF1E293B),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildGenderOption(
                                'Laki-laki',
                                'Laki-laki',
                                Icons.male,
                              ),
                              const SizedBox(width: 12),
                              _buildGenderOption(
                                'Perempuan',
                                'Perempuan',
                                Icons.female,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // 5. Birthdate
                          Text(
                            'Tanggal Lahir',
                            style: GoogleFonts.raleway(
                              color: const Color(0xFF1E293B),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _selectBirthdate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.transparent, // Clean look
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    color: Color(0xFF3F88EB),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _selectedBirthdate == null
                                        ? 'Pilh Tanggal Lahir'
                                        : _formatDate(_selectedBirthdate!),
                                    style: GoogleFonts.poppins(
                                      color: _selectedBirthdate == null
                                          ? Colors.grey[400]
                                          : Colors.black87,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.grey[600],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 6. Password
                          _buildTextField(
                            label: 'Password',
                            controller: _passwordController,
                            icon: Icons.lock_outline,
                            hint: '••••••••',
                            isPassword: true,
                            obscureText: _obscurePassword,
                            onVisibilityToggle: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            validator: (v) =>
                                v!.length < 8 ? 'Min 8 karakter' : null,
                          ),
                          const SizedBox(height: 20),

                          // 7. Confirm Password
                          _buildTextField(
                            label: 'Konfirmasi Password',
                            controller: _confirmPasswordController,
                            icon: Icons.lock_outline,
                            hint: '••••••••',
                            isPassword: true,
                            obscureText: _obscureConfirmPassword,
                            onVisibilityToggle: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                            validator: (v) => v != _passwordController.text
                                ? 'Password tidak sama'
                                : null,
                          ),

                          const SizedBox(height: 24),

                          // Terms Checkbox
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _acceptTerms,
                                  activeColor: const Color(0xFF3F88EB),
                                  onChanged: (val) {
                                    setState(() {
                                      _acceptTerms = val ?? false;
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text: 'Saya menyetujui ',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Syarat & Ketentuan',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF3F88EB),
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3F88EB),
                                foregroundColor: Colors.white,
                                elevation: 5,
                                shadowColor: const Color(0x403F88EB),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'Daftar Sekarang',
                                style: GoogleFonts.raleway(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0, top: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sudah punya akun? ',
                    style: GoogleFonts.raleway(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: Text(
                      'Masuk',
                      style: GoogleFonts.raleway(
                        color: const Color(0xFF8E2DE2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusing HeaderClipper from LoginScreen (duplicated here to avoid import issues if moved)
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height);
    var secondControlPoint = Offset(size.width * 3 / 4, size.height);
    var secondEndPoint = Offset(size.width, size.height - 50);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
