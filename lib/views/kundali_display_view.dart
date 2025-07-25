import 'package:flutter/material.dart';
import 'package:kundali_crypt/models/planets.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../controllers/astrology_controller.dart';
import '../models/kundali.dart';

class KundaliDisplayView extends StatefulWidget {
  @override
  _KundaliDisplayViewState createState() => _KundaliDisplayViewState();
}

class _KundaliDisplayViewState extends State<KundaliDisplayView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: () {
            // Hidden trigger - long press on title for 3 seconds
            Provider.of<AppController>(context, listen: false).triggerHiddenGesture();
          },
          child: Text('My Kundali'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => Provider.of<AppController>(context, listen: false).resetToPublic(),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<AppController>(
          builder: (context, appController, child) {
            final kundali = appController.kundali!;
            
            return IndexedStack(
              index: _currentIndex,
              children: [
                _buildChartView(kundali),
                _buildTodayView(),
                _buildInfoView(kundali),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Hidden trigger - triple tap on Saturn (Info) tab
          if (index == 2) {
            _handleInfoTap();
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Chart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Info',
          ),
        ],
      ),
    );
  }

  int _infoTapCount = 0;
  DateTime? _lastInfoTap;

  void _handleInfoTap() {
    final now = DateTime.now();
    if (_lastInfoTap == null || now.difference(_lastInfoTap!).inSeconds > 2) {
      _infoTapCount = 1;
    } else {
      _infoTapCount++;
    }
    _lastInfoTap = now;

    // Triple tap trigger
    if (_infoTapCount >= 3) {
      Provider.of<AppController>(context, listen: false).triggerHiddenGesture();
      _infoTapCount = 0;
    }
  }

  Widget _buildChartView(Kundali kundali) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Planetary Positions'),
          SizedBox(height: 16),
          ...kundali.planets.map((planet) => _buildPlanetCard(planet)).toList(),
          SizedBox(height: 24),
          _buildSectionHeader('Chart Details'),
          SizedBox(height: 16),
          _buildDetailCard('Ascendant', kundali.ascendant),
          _buildDetailCard('Nakshatra', kundali.nakshatra),
          _buildDetailCard('Birth Place', kundali.birthInfo.place),
        ],
      ),
    );
  }

  Widget _buildTodayView() {
    return Consumer<AstrologyController>(
      builder: (context, astrologyController, child) {
        final predictions = astrologyController.getDailyPrediction();
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Today\'s Guidance'),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.blue[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.wb_sunny, size: 48, color: Colors.orange),
                    SizedBox(height: 16),
                    Text(
                      'Daily Prediction',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    ...predictions.map((prediction) => Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        '• $prediction',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoView(Kundali kundali) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('About Kundali'),
          SizedBox(height: 16),
          _buildInfoCard(
            'Birth Information',
            'Date: ${kundali.birthInfo.dateTime.toString().split(' ')[0]}\n'
            'Time: ${kundali.birthInfo.dateTime.toString().split(' ')[1].substring(0, 5)}\n'
            'Place: ${kundali.birthInfo.place}',
          ),
          SizedBox(height: 16),
          _buildInfoCard(
            'Chart System',
            'This Kundali uses the Vedic astrology system based on sidereal calculations. '
            'The positions shown are accurate for the birth time and location provided.',
          ),
          SizedBox(height: 16),
          _buildInfoCard(
            'Interpretation',
            'Planetary positions influence different aspects of life. Each house represents '
            'specific life areas, and planetary placements provide insights into personality and destiny.',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildPlanetCard(Planet planet) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getPlanetColor(planet.type),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              _getPlanetIcon(planet.type),
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  planet.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${planet.house}${_getOrdinalSuffix(planet.house)} House, ${planet.sign}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPlanetColor(PlanetType type) {
    switch (type) {
      case PlanetType.sun: return Colors.orange;
      case PlanetType.moon: return Colors.blue[300]!;
      case PlanetType.mars: return Colors.red;
      case PlanetType.mercury: return Colors.green;
      case PlanetType.jupiter: return Colors.purple;
      case PlanetType.venus: return Colors.pink;
      case PlanetType.saturn: return Colors.indigo;
      case PlanetType.rahu: return Colors.brown;
      case PlanetType.ketu: return Colors.grey;
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

  String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) return 'th';
    switch (number % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }
}