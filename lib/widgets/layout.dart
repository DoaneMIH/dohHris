// import 'package:flutter/material.dart';

// class PersonalInformationCard extends StatelessWidget {
//   final String title;
//   final List<PersonalInfoRow> rows;
//   final Color? headerColor;

//   const PersonalInformationCard({
//     Key? key,
//     required this.title,
//     required this.rows,
//     this.headerColor,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Header
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               color: headerColor ?? const Color(0xFF2C5F4F),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(8),
//                 topRight: Radius.circular(8),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 13,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Content
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 for (int i = 0; i < rows.length; i++) ...[
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _buildInfoField(
//                           rows[i].leftLabel,
//                           rows[i].leftValue,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: _buildInfoField(
//                           rows[i].rightLabel,
//                           rows[i].rightValue,
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (i < rows.length - 1) const SizedBox(height: 12),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoField(String label, dynamic value) {
//     String displayValue = '';
//     if (value != null && 
//         value.toString().isNotEmpty && 
//         value.toString() != 'null') {
//       displayValue = value.toString();
//     }

//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(4),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 10,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             displayValue,
//             style: const TextStyle(
//               fontSize: 13,
//               color: Colors.black87,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class PersonalInfoRow {
//   final String leftLabel;
//   final dynamic leftValue;
//   final String rightLabel;
//   final dynamic rightValue;

//   PersonalInfoRow({
//     required this.leftLabel,
//     this.leftValue,
//     required this.rightLabel,
//     this.rightValue,
//   });
// }