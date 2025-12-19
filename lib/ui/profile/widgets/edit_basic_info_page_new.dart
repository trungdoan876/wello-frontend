import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class EditBasicInfoPage extends StatefulWidget {
  final String nickname;
  final String gender;
  final int age;
  final int height;

  const EditBasicInfoPage({
    super.key,
    required this.nickname,
    required this.gender,
    required this.age,
    required this.height,
  });

  @override
  State<EditBasicInfoPage> createState() => _EditBasicInfoPageState();
}

class _EditBasicInfoPageState extends State<EditBasicInfoPage> {
  late String _nickname;
  late String _gender;
  late int _age;
  late int _height;

  @override
  void initState() {
    super.initState();
    _nickname = widget.nickname;
    _gender = widget.gender;
    _age = widget.age;
    _height = widget.height;
  }

  void _editField(String fieldName, dynamic currentValue) {
    TextEditingController controller = TextEditingController(
      text: currentValue.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF6D5),
        title: Text(
          'Chỉnh sửa $fieldName',
          style: GoogleFonts.baloo2(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4C494C),
          ),
        ),
        content: fieldName == 'Giới tính'
            ? DropdownButton<String>(
                value: _gender,
                isExpanded: true,
                items: ['Nam', 'Nữ']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _gender = value);
                    Navigator.pop(context);
                  }
                },
              )
            : TextField(
                controller: controller,
                keyboardType: fieldName == 'Tuổi' || fieldName == 'Chiều cao'
                    ? TextInputType.number
                    : TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
        actions: fieldName != 'Giới tính'
            ? [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () {
                    final value = controller.text;
                    if (value.isNotEmpty) {
                      setState(() {
                        if (fieldName == 'Nickname') _nickname = value;
                        if (fieldName == 'Tuổi')
                          _age = int.tryParse(value) ?? _age;
                        if (fieldName == 'Chiều cao')
                          _height = int.tryParse(value) ?? _height;
                      });
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Lưu'),
                ),
              ]
            : [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFFFF6D5);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4C494C)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: Text(
          'Thông tin cơ bản',
          style: GoogleFonts.baloo2(
            color: const Color(0xFFEACF2C),
            fontWeight: FontWeight.w800,
            fontSize: context.sp(7.5),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(0.05),
          vertical: context.h(0.02),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: context.h(0.02)),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _EditableRow(
                    label: 'Nickname',
                    value: _nickname,
                    onTap: () => _editField('Nickname', _nickname),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E2E2)),
                  _EditableRow(
                    label: 'Giới tính',
                    value: _gender,
                    onTap: () => _editField('Giới tính', _gender),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E2E2)),
                  _EditableRow(
                    label: 'Tuổi',
                    value: '$_age',
                    onTap: () => _editField('Tuổi', _age),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E2E2)),
                  _EditableRow(
                    label: 'Chiều cao',
                    value: '$_height cm',
                    onTap: () => _editField('Chiều cao', _height),
                    isLast: true,
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

class _EditableRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isLast;

  const _EditableRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(0.04),
          vertical: context.h(0.015),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.baloo2(
                fontSize: context.sp(5.2),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF999999),
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(5.2),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4C494C),
                  ),
                ),
                SizedBox(width: context.w(0.02)),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Color(0xFFB0AEB0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
