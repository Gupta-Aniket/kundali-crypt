import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kundali_crypt/models/planets.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../controllers/vault_controller.dart';


class PatternUnlockView extends StatefulWidget {
  @override
  _PatternUnlockViewState createState() => _PatternUnlockViewState();
}

class _PatternUnlockViewState extends State<PatternUnlockView> 
    with TickerProviderStateMixin {
  late AnimationController _orbitController;
  late AnimationController _glowController;
  late Animation<double> _orbitAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _glowController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _orbitAnimation = Tween<double>(begin: 0, end: 1).animate(_orbitController);
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      body: SafeArea(
        child: Stack(
          children: [
            // Background stars
            ...List.generate(50, (index) => _buildStar(index)),
            
            // Main content
            Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Celestial Vault',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Draw your pattern across the planets',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Pattern display
                Expanded(
                  child: Consumer<VaultController>(
                    builder: (context, vaultController, child) {
                      return Column(
                        children: [
                          // Current pattern
                          Container(
                            height: 60,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Pattern: ',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                                ...vaultController.currentPattern.map((planet) => 
                                  Container(
                                    margin: EdgeInsets.only(right: 8),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12, 
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getPlanetColor(planet),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _getPlanetColor(planet).withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      _getPlanetName(planet),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ).toList(),
                              ],
                            ),
                          ),
                          
                          // Planet grid
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _orbitAnimation,
                              builder: (context, child) {
                                return _buildPlanetGrid(vaultController);
                              },
                            ),
                          ),
                          
                          // Action buttons
                          Padding(
                            padding: EdgeInsets.all(24),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: vaultController.currentPattern.isEmpty 
                                      ? null 
                                      : () => vaultController.clearPattern(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[600],
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text('Clear'),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed: vaultController.currentPattern.length < 4
                                      ? null
                                      : () => _unlockVault(vaultController),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text('Unlock Vault'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            
            // Back button
            Positioned(
              top: 50,
              left: 20,
              child: IconButton(
                onPressed: () {
                  Provider.of<AppController>(context, listen: false).resetToPublic();
                },
                icon: Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStar(int index) {
    final random = index * 123; // Pseudo-random
    final left = (random % 100) / 100 * MediaQuery.of(context).size.width;
    final top = ((random * 7) % 100) / 100 * MediaQuery.of(context).size.height;
    final size = ((random * 3) % 4) + 1.0;
    
    return Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(_glowAnimation.value * 0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 2,
                  spreadRadius: 1,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanetGrid(VaultController vaultController) {
    return GridView.builder(
      padding: EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1,
      ),
      itemCount: PlanetType.values.length,
      itemBuilder: (context, index) {
        final planet = PlanetType.values[index];
        final isSelected = vaultController.currentPattern.contains(planet);
        
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            if (isSelected) {
              vaultController.removeFromPattern(planet);
            } else {
              vaultController.addToPattern(planet);
            }
          },
          child: AnimatedBuilder(
            animation: _orbitAnimation,
            builder: (context, child) {
              final rotationOffset = index * 0.2;
              final rotation = (_orbitAnimation.value + rotationOffset) * 2 * 3.14159;
              
              return Transform.rotate(
                angle: rotation * 0.1, // Subtle rotation
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _getPlanetColor(planet).withOpacity(0.8),
                        _getPlanetColor(planet).withOpacity(0.3),
                      ],
                    ),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getPlanetColor(planet).withOpacity(0.5),
                        blurRadius: isSelected ? 20 : 10,
                        spreadRadius: isSelected ? 5 : 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getPlanetIcon(planet),
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        _getPlanetName(planet),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _unlockVault(VaultController vaultController) async {
    final appController = Provider.of<AppController>(context, listen: false);
    
    // Default pattern for demo - in production, this would be user-set
    const correctPattern = '1,2,6,8'; // Moon, Mars, Saturn, Ketu
    
    HapticFeedback.mediumImpact();
    
    final success = await vaultController.unlockVault(
      appController.kundali!.planets, 
      correctPattern,
    );
    
    if (success) {
      HapticFeedback.heavyImpact();
      appController.switchMode(AppMode.vault);
    } else {
      // Wrong pattern feedback
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pattern must have at least 4 planets'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getPlanetColor(PlanetType type) {
    switch (type) {
      case PlanetType.sun: return Color(0xFFFF6B35);
      case PlanetType.moon: return Color(0xFF4A90E2);
      case PlanetType.mars: return Color(0xFFE74C3C);
      case PlanetType.mercury: return Color(0xFF2ECC71);
      case PlanetType.jupiter: return Color(0xFF9B59B6);
      case PlanetType.venus: return Color(0xFFE91E63);
      case PlanetType.saturn: return Color(0xFF34495E);
      case PlanetType.rahu: return Color(0xFF795548);
      case PlanetType.ketu: return Color(0xFF607D8B);
    }
  }

  IconData _getPlanetIcon(PlanetType type) {
    switch (type) {
      case PlanetType.sun: return Icons.wb_sunny;
      case PlanetType.moon: return Icons.nightlight_round;
      case PlanetType.mars: return Icons.rocket_launch;
      case PlanetType.mercury: return Icons.speed;
      case PlanetType.jupiter: return Icons.expand;
      case PlanetType.venus: return Icons.favorite;
      case PlanetType.saturn: return Icons.schedule;
      case PlanetType.rahu: return Icons.trending_up;
      case PlanetType.ketu: return Icons.trending_down;
    }
  }

  String _getPlanetName(PlanetType type) {
    switch (type) {
      case PlanetType.sun: return 'Sun';
      case PlanetType.moon: return 'Moon';
      case PlanetType.mars: return 'Mars';
      case PlanetType.mercury: return 'Mercury';
      case PlanetType.jupiter: return 'Jupiter';
      case PlanetType.venus: return 'Venus';
      case PlanetType.saturn: return 'Saturn';
      case PlanetType.rahu: return 'Rahu';
      case PlanetType.ketu: return 'Ketu';
    }
  }
}