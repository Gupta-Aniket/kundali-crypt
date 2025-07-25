import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../controllers/astrology_controller.dart';
import '../models/birth_info.dart';

class BirthFormView extends StatefulWidget {
  @override
  _BirthFormViewState createState() => _BirthFormViewState();
}

class _BirthFormViewState extends State<BirthFormView> {
  final _formKey = GlobalKey<FormState>();
  final _placeController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Kundali'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40),
              Text(
                'Enter Birth Details',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Generate your personalized birth chart',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),

              // Date Picker
              _buildDateTimeField(
                'Date of Birth',
                _selectedDate?.toString().split(' ')[0] ?? 'Select Date',
                Icons.calendar_today,
                () => _selectDate(context),
              ),
              SizedBox(height: 20),

              // Time Picker
              _buildDateTimeField(
                'Time of Birth',
                _selectedTime?.format(context) ?? 'Select Time',
                Icons.access_time,
                () => _selectTime(context),
              ),
              SizedBox(height: 20),

              // Place Field
              TextFormField(
                controller: _placeController,
                decoration: InputDecoration(
                  labelText: 'Place of Birth',
                  hintText: 'Enter city, country',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter place of birth';
                  }
                  return null;
                },
              ),

              Spacer(),

              // Generate Button
              Consumer<AppController>(
                builder: (context, appController, child) {
                  return ElevatedButton(
                    onPressed:
                        appController.isLoading ? null : _generateKundali,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child:
                        appController.isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                              'Generate Kundali',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeField(
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600]),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _generateKundali() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      final appController = Provider.of<AppController>(context, listen: false);
      final astrologyController = Provider.of<AstrologyController>(
        context,
        listen: false,
      );

      appController.setLoading(true);

      final birthInfo = BirthInfo(
        dateTime: DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        ),
        place: _placeController.text,
        latitude: 28.7041, // Default to Delhi coordinates
        longitude: 77.1025,
      );

      appController.setBirthInfo(birthInfo);

      try {
        final kundali = await astrologyController.generateKundali(birthInfo);
        appController.setKundali(kundali);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating Kundali: $e')));
      } finally {
        appController.setLoading(false);
      }
    }
  }
}
