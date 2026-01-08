import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import 'history.dart';
import 'statistics.dart'; // <--- JANGAN LUPA IMPORT INI DI ATAS FILE
// --- THEME CONSTANTS ---

class AppTheme {
  static const Color darkGreen = Color(0xFF1B4332);
  static const Color primaryGreen = Color(0xFF2D6A4F);
  static const Color lightGreen = Color(0xFFD8F3DC);
  static const Color accent = Color(0xFF95D5B2);
  static const Color surface = Color(0xFFF8F9FA);
  
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(32));
  static const BoxShadow softShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 20,
    offset: Offset(0, 10),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final viewModel = Provider.of<HomeViewModel>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        children: [
          // 1. Background Elements (Subtle Organic Shapes)
          const _BackgroundDecorations(),

          // 2. Main Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom Collapsing App Bar
              SliverAppBar(
                expandedHeight: 120,
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                  title: Text(
                    'Trash Classifier',
                    style: TextStyle(
                      color: AppTheme.darkGreen,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      fontSize: 24,
                      shadows: [
                        Shadow(color: Colors.white.withOpacity(0.5), blurRadius: 10),
                      ],
                    ),
                  ),
                ),
                
// ... di dalam SliverAppBar actions ...

actions: [

  // Tombol Statistik Baru

  IconButton(

    onPressed: () {

      Navigator.push(

        context,

        MaterialPageRoute(builder: (context) => const StatisticsScreen()),

      );

    },

    icon: Container(

      padding: const EdgeInsets.all(8),

      decoration: BoxDecoration(

        color: Colors.white,

        shape: BoxShape.circle,

        boxShadow: [

          BoxShadow(

            color: Colors.black.withOpacity(0.05),

            blurRadius: 10,

          )

        ],

      ),

      child: const Icon(Icons.bar_chart_rounded, color: AppTheme.darkGreen, size: 20),

    ),

  ),

  

  const SizedBox(width: 12),

  

  // Tombol History Lama (Tetap ada)

  _HistoryButton(onPressed: () {

    Navigator.push(

      context,

      MaterialPageRoute(builder: (context) => const History()),

    );

  }),

  const SizedBox(width: 24),

],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // Image Display Area
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _ImageDisplayArea(viewModel: viewModel),
                      ),
                      
                      const SizedBox(height: 32),

                      // Action Buttons
                      SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
                            .animate(_slideAnimation),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _ControlPanel(viewModel: viewModel),
                        ),
                      ),
                      
                      const SizedBox(height: 32),

                      // Analysis Results
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: viewModel.isProcessing
                            ? const _ProcessingState()
                            : viewModel.classificationResult != null
                                ? _ResultPanel(
                                    result: viewModel.classificationResult!,
                                    recommendation: viewModel.geminiRecommendation,
                                  )
                                : const SizedBox.shrink(),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- SUB-WIDGETS ---

class _ImageDisplayArea extends StatelessWidget {
  final HomeViewModel viewModel;

  const _ImageDisplayArea({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardRadius,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppTheme.cardRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (viewModel.selectedImage != null)
              Image.file(
                viewModel.selectedImage!,
                fit: BoxFit.cover,
              )
            else
              _buildPlaceholder(),
              
            // Gradient Overlay for text readability if image exists
            if (viewModel.selectedImage != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        border: Border.all(color: AppTheme.lightGreen, width: 2),
        borderRadius: AppTheme.cardRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_a_photo_rounded,
              size: 48,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Start Analysis',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload a photo to classify waste',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.darkGreen.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlPanel extends StatelessWidget {
  final HomeViewModel viewModel;

  const _ControlPanel({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GlassButton(
            icon: Icons.camera_alt_outlined,
            label: "Camera",
            isPrimary: true,
            onTap: () => viewModel.pickAndProcessImage(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _GlassButton(
            icon: Icons.photo_library_outlined,
            label: "Gallery",
            isPrimary: false,
            onTap: () => viewModel.pickAndProcessImage(ImageSource.gallery),
          ),
        ),
      ],
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _GlassButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isPrimary ? null : Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: isPrimary 
                  ? AppTheme.primaryGreen.withOpacity(0.3) 
                  : Colors.grey.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : AppTheme.darkGreen,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : AppTheme.darkGreen,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProcessingState extends StatelessWidget {
  const _ProcessingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardRadius,
        boxShadow: [AppTheme.softShadow],
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 40,
            width: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Analyzing Composition...",
            style: TextStyle(
              color: AppTheme.darkGreen,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Identifying materials and recycling steps",
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
class _ResultPanel extends StatelessWidget {
  final String result;
  final String? recommendation;

  const _ResultPanel({
    super.key, // Tambahkan super.key best practice
    required this.result,
    this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Parsing logic: Memisahkan Fun Fact dan Langkah-langkah
    String funFact = "";
    List<String> steps = [];

    if (recommendation != null) {
      final text = recommendation!;
      
      // Coba parsing sederhana berdasarkan format prompt Gemini
      if (text.contains("HOW TO RECYCLE:")) {
        final parts = text.split("HOW TO RECYCLE:");
        
        // Ambil Fun Fact (hapus label 'FUN FACT:')
        funFact = parts[0].replaceAll("FUN FACT:", "").trim();
        
        // Ambil langkah-langkah (split berdasarkan baris baru)
        final rawSteps = parts[1].trim().split("\n");
        steps = rawSteps
            .where((s) => s.trim().isNotEmpty)
            .map((s) => s.replaceAll(RegExp(r'^\d+\.\s*'), '')) // Hapus nomor bawaan teks (1., 2.)
            .toList();
      } else {
        // Fallback jika format tidak sesuai
        funFact = text; 
      }
    }

    return ClipRRect(
      borderRadius: AppTheme.cardRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95), // Sedikit lebih solid agar teks terbaca
            borderRadius: AppTheme.cardRadius,
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
            boxShadow: [AppTheme.softShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- HEADER (Hasil Klasifikasi) ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.08),
                  border: Border(bottom: BorderSide(color: AppTheme.primaryGreen.withOpacity(0.1))),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "IDENTIFIED OBJECT",
                            style: TextStyle(
                              color: AppTheme.darkGreen.withOpacity(0.6),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            result, // Menampilkan hasil klasifikasi (misal: "Plastic Bottle")
                            style: const TextStyle(
                              color: AppTheme.darkGreen,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- BODY CONTENT ---
              Padding(
                padding: const EdgeInsets.all(24),
                child: recommendation == null
                    ? _buildShimmerLoading()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Fun Fact Card
                          if (funFact.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9), // Light green background
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.lightbulb_outline, color: AppTheme.primaryGreen, size: 22),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Did you know?",
                                          style: TextStyle(
                                            color: AppTheme.primaryGreen,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          funFact,
                                          style: TextStyle(
                                            color: AppTheme.darkGreen.withOpacity(0.8),
                                            fontSize: 14,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // 2. Recycling Steps Header
                          if (steps.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(Icons.recycling, color: AppTheme.darkGreen.withOpacity(0.7), size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  "Recycling Steps",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.darkGreen,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // 3. List of Steps
                            ...steps.asMap().entries.map((entry) {
                              int idx = entry.key + 1;
                              String stepText = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: AppTheme.darkGreen,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.darkGreen.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          )
                                        ],
                                      ),
                                      child: Text(
                                        "$idx",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        stepText,
                                        style: TextStyle(
                                          fontSize: 14,
                                          height: 1.5,
                                          color: Colors.grey[800],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ] else ...[
                            // Tampilkan teks raw jika parsing gagal
                            Text(
                              funFact,
                              style: const TextStyle(color: Colors.black87),
                            )
                          ]
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Efek loading saat menunggu respons AI
  Widget _buildShimmerLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 20),
        Container(height: 16, width: 120, color: Colors.grey[100]),
        const SizedBox(height: 12),
        for (int i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(width: 24, height: 24, decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Expanded(child: Container(height: 14, color: Colors.grey[100])),
              ],
            ),
          ),
      ],
    );
  }
}

class _HistoryButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _HistoryButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          highlightColor: AppTheme.lightGreen,
        ),
        icon: const Icon(
          Icons.history_rounded,
          color: AppTheme.darkGreen,
          size: 24,
        ),
      ),
    );
  }
}

class _BackgroundDecorations extends StatelessWidget {
  const _BackgroundDecorations();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top Right Blob
        Positioned(
          top: -100,
          right: -50,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppTheme.lightGreen.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        
        // Bottom Left Blob
        Positioned(
          bottom: 100,
          left: -80,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7FA).withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}