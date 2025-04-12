import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventory_management_system/utility/theme.dart';
import 'package:inventory_management_system/widgets/custom_input_field.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../utility/constants.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/data_input_field.dart';
import '../../../utility/icon_assets.dart';

class CustomerBillingScreen extends StatefulWidget {
  const CustomerBillingScreen({super.key});

  @override
  State<CustomerBillingScreen> createState() => _CustomerBillingScreenState();
}

class _CustomerBillingScreenState extends State<CustomerBillingScreen> {
  final TextEditingController customerNameController = TextEditingController();
  final List<Map<String, dynamic>> medicines = [];
  String? selectedMedicineId;
  int selectedQuantity = 1;
  double selectedMedicinePrice = 0.0;
  double totalPrice = 0.0;
  String? pharmacistName;
  String? pharmacistId;
  String selectedMedicineName = '';
  int? editingIndex; // Index of the medicine being edited


  @override
  void initState() {
    super.initState();
    _loadPharmacistInfo();
  }

  Future<void> _loadPharmacistInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      pharmacistId = user.uid;
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      pharmacistName = userDoc['name'] ?? "Unknown";
      setState(() {});
    }
  }

  Stream<QuerySnapshot> fetchMedicines() {
    return FirebaseFirestore.instance.collection('medicines').snapshots();
  }

  void addMedicine(Map<String, dynamic> medicineData) async {
    String medicineName = medicineData['name'];
    double price = medicineData['price'];
    int availableQuantity = medicineData['quantity'];

    if (selectedQuantity > availableQuantity) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Not enough stock available!")));
      return;
    }

    setState(() {
      double total = price * selectedQuantity;
      medicines.add({
        "medicine": medicineName,
        "quantity": selectedQuantity,
        "price": total,
      });
      totalPrice += total;
    });

    int newQuantity = availableQuantity - selectedQuantity;
    await FirebaseFirestore.instance
        .collection('medicines')
        .doc(medicineData['id'])
        .update({"quantity": newQuantity});
  }

  Future<void> saveBillToFirestore() async {
    if (customerNameController.text.isEmpty || medicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter customer name and add medicines."),
        ),
      );
      return;
    }

    DocumentReference billRef = await FirebaseFirestore.instance
        .collection('bills')
        .add({
          'customerName': customerNameController.text,
          'medicines': medicines,
          'totalPrice': totalPrice,
          'date': FieldValue.serverTimestamp(), // Save as Timestamp
          'pharmacistId': pharmacistId,
          'pharmacistName': pharmacistName,
        });

    // Update with bill ID
    await billRef.update({'billId': billRef.id});

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Bill saved successfully!")));

    // Clear fields after saving
    customerNameController.clear();
    setState(() {
      medicines.clear();
      totalPrice = 0.0;
      selectedMedicineId = null;
      selectedMedicineName = '';
      selectedQuantity = 1;
      selectedMedicinePrice = 0.0;
    });
  }

  Future<void> generateAndDownloadPDF() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build:
              (pw.Context context) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "Customer Billing Receipt",
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    "Customer Name: ${customerNameController.text}",
                    style: pw.TextStyle(fontSize: 18),
                  ),
                  pw.Text(
                    "Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
                    style: pw.TextStyle(fontSize: 18),
                  ),
                  pw.Text(
                    "Pharmacist: ${pharmacistName ?? 'Unknown'}",
                    style: pw.TextStyle(fontSize: 18),
                  ),
                  pw.Divider(),
                  pw.Text(
                    "Items:",
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Column(
                    children:
                        medicines.map((medicine) {
                          return pw.Text(
                            "${medicine['medicine']} - ${medicine['quantity']} pcs - ${medicine['price']}",
                          );
                        }).toList(),
                  ),
                  pw.Divider(),
                  pw.Text(
                    "Total Price: ${totalPrice.toStringAsFixed(2)}",
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
        ),
      );

      final directory = await getTemporaryDirectory();
      final filePath = "${directory.path}/bill.pdf";
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(filePath);
    } catch (e) {
      print("Error generating PDF: $e");
    }
  }

  Stream<QuerySnapshot> fetchPreviousBills() {
    if (pharmacistId == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('bills')
        .where('pharmacistId', isEqualTo: pharmacistId)
        .orderBy('date', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppbar(text: "Customer Billing", icon: IconAssets.medIcon),
              const SizedBox(height: 20),

              CustomInputField(
                labelText: "Customer Name",
                controller: customerNameController,
              ),
              const SizedBox(height: 20),

              // Medicine Dropdown
              StreamBuilder<QuerySnapshot>(
                stream: fetchMedicines(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  var medicineList = snapshot.data!.docs;

                  if (medicineList.isEmpty) {
                    return Text(
                      "No medicines available",
                      style: TextStyle(color: Colors.red),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Autocomplete<Map<String, dynamic>>(
                        displayStringForOption: (medicine) => medicine['name'],
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return const Iterable<Map<String, dynamic>>.empty();
                          }
                          return medicineList
                              .map(
                                (doc) => {
                                  'id': doc.id,
                                  'name': doc['name'],
                                  'quantity': doc['quantity'],
                                  'price': doc['price'],
                                },
                              )
                              .where(
                                (medicine) =>
                                    medicine['name'].toLowerCase().contains(
                                      textEditingValue.text.toLowerCase(),
                                    ),
                              );
                        },
                        onSelected: (Map<String, dynamic> selection) {
                          setState(() {
                            selectedMedicineId = selection['id'];
                            selectedMedicinePrice = selection['price'];
                            selectedMedicineName = selection['name'];
                          });
                        },
                        fieldViewBuilder: (
                            BuildContext context,
                            TextEditingController textEditingController,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted,
                            ) {
                          textEditingController.text = selectedMedicineName;
                          return SizedBox(
                            width: AppSizes.wp(330),
                            height: AppSizes.hp(69),
                            child: TextField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                labelText: "Medicine Name",
                                hintStyle: TextStyle(
                                  fontSize: AppSizes.sp(14),
                                  color: AppTheme.lightTextColorDark.withOpacity(0.7),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(color: AppTheme.primaryColor, width: 3),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(color: AppTheme.primaryColor, width: 3),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(color: Colors.red, width: 2),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 10),

                      Row(
                        children: [
                          Text("Quantity:"),
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              if (selectedQuantity > 1) {
                                setState(() => selectedQuantity--);
                              }
                            },
                          ),
                          Text(selectedQuantity.toString()),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => setState(() => selectedQuantity++),
                          ),
                        ],
                      ),

                      Text(
                        "Total: ${(selectedMedicinePrice * selectedQuantity).toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),
                      editingIndex != null
                          ? Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: "Update",
                              onPressed: () {
                                final updatedMed = {
                                  'medicine': selectedMedicineName,
                                  'quantity': selectedQuantity,
                                  'price': selectedQuantity * selectedMedicinePrice,
                                };

                                setState(() {
                                  totalPrice -= (medicines[editingIndex!]['price'] as num).toDouble();
                                  medicines[editingIndex!] = updatedMed;
                                  totalPrice += updatedMed['price'] as double;
                                  editingIndex = null;
                                  selectedMedicineId = null;
                                  selectedMedicineName = '';
                                  selectedQuantity = 1;
                                  selectedMedicinePrice = 0.0;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: CustomButton(
                              text: "Delete",
                              onPressed: () {
                                setState(() {
                                  totalPrice -= (medicines[editingIndex!]['price'] as num).toDouble();
                                  medicines.removeAt(editingIndex!);
                                  editingIndex = null;
                                  selectedMedicineId = null;
                                  selectedMedicineName = '';
                                  selectedQuantity = 1;
                                  selectedMedicinePrice = 0.0;
                                });
                              },
                            ),
                          ),
                        ],
                      )
                          : CustomButton(
                        text: "Add Medicine",
                        onPressed: () {
                          if (selectedMedicineId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Please select a medicine!")),
                            );
                            return;
                          }

                          var selectedMedData = medicineList.firstWhere(
                                (doc) => doc.id == selectedMedicineId,
                          );
                          addMedicine({
                            "id": selectedMedicineId,
                            "name": selectedMedData['name'],
                            "quantity": (selectedMedData['quantity'] as num).toInt(),
                            "price": (selectedMedData['price'] as num).toDouble(),
                          });
                        },
                      ),


                      // CustomButton(
                      //   text: "Add Medicine",
                      //   onPressed: () {
                      //     if (selectedMedicineId == null) {
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         SnackBar(
                      //           content: Text("Please select a medicine!"),
                      //         ),
                      //       );
                      //       return;
                      //     }
                      //
                      //     var selectedMedData = medicineList.firstWhere(
                      //       (doc) => doc.id == selectedMedicineId,
                      //     );
                      //     addMedicine({
                      //       "id": selectedMedicineId,
                      //       "name": selectedMedData['name'],
                      //       "quantity": selectedMedData['quantity'],
                      //       "price": selectedMedData['price'],
                      //     });
                      //   },
                      // ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),
              Text(
                "Medicines List:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: medicines.length,
                itemBuilder: (context, index) {
                  final med = medicines[index];
                  return Card(
                    child: ListTile(
                      onTap: () {
                        final med = medicines[index];
                        setState(() {
                          editingIndex = index;
                          selectedMedicineName = med['medicine'];
                          selectedQuantity = med['quantity'];
                          selectedMedicinePrice = med['price'] / med['quantity']; // Recalculate unit price
                        });
                      },
                      title: Text("${med['medicine']} - ${med['quantity']} pcs"),
                      subtitle: Text("Price: ${med['price'].toStringAsFixed(2)}"),
                    )

                  );
                },
              ),

              const SizedBox(height: 20),
              Text(
                "Total Price: ${totalPrice.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CustomButton(
                    onPressed: () async {
                      // Call the function to save data here
                      await saveBillToFirestore();
                    },
                    text: 'Save',
                  ),
                  const SizedBox(width: 70),
                  CustomButton(
                    text: "Print",
                    onPressed: generateAndDownloadPDF,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import '../../../widgets/custom_appbar.dart';
// import '../../../widgets/custom_button.dart';
// import '../../../widgets/data_input_field.dart';
// import '../../../utility/icon_assets.dart';
// import 'package:intl/intl.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:open_file/open_file.dart';
//
// class CustomerBillingScreen extends StatefulWidget {
//   const CustomerBillingScreen({super.key});
//
//   @override
//   State<CustomerBillingScreen> createState() => _CustomerBillingScreenState();
// }
//
// class _CustomerBillingScreenState extends State<CustomerBillingScreen> {
//   final TextEditingController customerNameController = TextEditingController();
//   final List<Map<String, dynamic>> medicines = [
//   ]; // Stores selected medicines for billing
//   String? selectedMedicineId; // Selected medicine Firestore ID
//   int selectedQuantity = 1; // Default quantity
//   double selectedMedicinePrice = 0.0; // Price per unit of selected medicine
//   double totalPrice = 0.0;
//
//   // Fetch available medicines in real-time
//   Stream<QuerySnapshot> fetchMedicines() {
//     return FirebaseFirestore.instance
//         .collection('medicines')
//         .snapshots();
//   }
//
//   // Function to add a selected medicine to the bill
//   void addMedicine(Map<String, dynamic> medicineData) async {
//     String medicineName = medicineData['name'];
//     double price = medicineData['price'];
//     int availableQuantity = medicineData['quantity'];
//
//     if (selectedQuantity > availableQuantity) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Not enough stock available!")),
//       );
//       return;
//     }
//
//     setState(() {
//       double total = price * selectedQuantity;
//       medicines.add({
//         "medicine": medicineName,
//         "quantity": selectedQuantity,
//         "price": total,
//       });
//
//       totalPrice += total;
//     });
//
//     // Update the medicine quantity in Firestore
//     int newQuantity = availableQuantity - selectedQuantity;
//     await FirebaseFirestore.instance
//         .collection('medicines')
//         .doc(medicineData['id'])
//         .update({"quantity": newQuantity});
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("$medicineName added to bill")),
//     );
//   }
//
//   // Function to save the bill to Firestore
//   void saveBillToFirestore() async {
//     if (customerNameController.text.isEmpty || medicines.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(
//             "Please enter customer name and add at least one medicine!")),
//       );
//       return;
//     }
//
//     String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
//
//     await FirebaseFirestore.instance.collection('bills').add({
//       'customerName': customerNameController.text,
//       'medicines': medicines,
//       'totalPrice': totalPrice,
//       'date': date,
//     });
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Bill saved successfully!")),
//     );
//
//     // Clear fields after saving
//     customerNameController.clear();
//     setState(() {
//       medicines.clear();
//       totalPrice = 0.0;
//       selectedMedicineId = null;
//       selectedQuantity = 1;
//       selectedMedicinePrice = 0.0;
//     });
//   }
//
//   // Function to generate and download PDF
//   Future<void> generateAndDownloadPDF() async {
//     try {
//       final pdf = pw.Document();
//
//       pdf.addPage(
//         pw.Page(
//           build: (pw.Context context) =>
//               pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Text("Customer Billing Receipt",
//                       style: pw.TextStyle(
//                           fontSize: 24, fontWeight: pw.FontWeight.bold)),
//                   pw.SizedBox(height: 10),
//                   pw.Text("Customer Name: ${customerNameController.text}",
//                       style: pw.TextStyle(fontSize: 18)),
//                   pw.Text("Date: ${DateFormat('yyyy-MM-dd').format(
//                       DateTime.now())}",
//                       style: pw.TextStyle(fontSize: 18)),
//                   pw.Divider(),
//                   pw.Text("Items:",
//                       style: pw.TextStyle(
//                           fontSize: 20, fontWeight: pw.FontWeight.bold)),
//                   pw.Column(
//                     children: medicines.map((medicine) {
//                       return pw.Text(
//                           "${medicine['medicine']} - ${medicine['quantity']} pcs - ${medicine['price']}");
//                     }).toList(),
//                   ),
//                   pw.Divider(),
//                   pw.Text("Total Price: ${totalPrice.toStringAsFixed(2)}",
//                       style: pw.TextStyle(
//                           fontSize: 20, fontWeight: pw.FontWeight.bold)),
//                 ],
//               ),
//         ),
//       );
//
//       // Get temporary directory
//       final directory = await getTemporaryDirectory();
//       final filePath = "${directory.path}/bill.pdf";
//       final file = File(filePath);
//
//       // Write the PDF to the file
//       await file.writeAsBytes(await pdf.save());
//
//       // Open the PDF
//       await OpenFile.open(filePath);
//
//       print("PDF saved at: $filePath");
//     } catch (e) {
//       print("Error generating PDF: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CustomAppbar(
//                     text: "Customer Billing", icon: IconAssets.medIcon),
//                 const SizedBox(height: 20),
//
//                 // Customer Name Input
//                 DataInputField(
//                   labelText: "Customer Name",
//                   hintText: "Enter customer's name",
//                   controller: customerNameController,
//                 ),
//                 const SizedBox(height: 20),
//
//                 // Medicine Dropdown with real-time updates
//                 StreamBuilder<QuerySnapshot>(
//                   stream: fetchMedicines(),
//                   builder: (context, snapshot) {
//                     if (!snapshot.hasData) {
//                       return CircularProgressIndicator();
//                     }
//
//                     var medicineList = snapshot.data!.docs;
//                     if (medicineList.isEmpty) {
//                       return Text("No medicines available",
//                           style: TextStyle(color: Colors.red));
//                     }
//
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("Select Medicine:", style: TextStyle(
//                             fontSize: 16)),
//                         DropdownButton<String>(
//                           value: selectedMedicineId,
//                           hint: Text("Choose a medicine"),
//                           isExpanded: true,
//                           items: medicineList.map((doc) {
//                             Map<String, dynamic> data = doc.data() as Map<
//                                 String,
//                                 dynamic>;
//                             return DropdownMenuItem<String>(
//                               value: doc.id,
//                               child: Text(
//                                   "${data['name']} - ${data['quantity']} pcs"),
//                               onTap: () {
//                                 setState(() {
//                                   selectedMedicinePrice =
//                                   data['price']; // Update price per unit
//                                 });
//                               },
//                             );
//                           }).toList(),
//                           onChanged: (value) {
//                             setState(() {
//                               selectedMedicineId = value;
//                               selectedQuantity =
//                               1; // Reset quantity when changing medicine
//                             });
//                           },
//                         ),
//                         const SizedBox(height: 10),
//
//                         // Quantity Selector with auto price calculation
//                         Row(
//                           children: [
//                             Text("Quantity:"),
//                             IconButton(
//                               icon: Icon(Icons.remove),
//                               onPressed: () {
//                                 if (selectedQuantity > 1) {
//                                   setState(() {
//                                     selectedQuantity--;
//                                   });
//                                 }
//                               },
//                             ),
//                             Text(selectedQuantity.toString()),
//                             IconButton(
//                               icon: Icon(Icons.add),
//                               onPressed: () {
//                                 setState(() {
//                                   selectedQuantity++;
//                                 });
//                               },
//                             ),
//                           ],
//                         ),
//
//                         // Show calculated price
//                         Text(
//                           "Total: ${(selectedMedicinePrice * selectedQuantity)
//                               .toStringAsFixed(2)}",
//                           style: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//
//                         const SizedBox(height: 10),
//
//                         // Add Medicine Button
//                         CustomButton(
//                           text: "Add Medicine",
//                           onPressed: () {
//                             if (selectedMedicineId == null) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                     content: Text("Please select a medicine!")),
//                               );
//                               return;
//                             }
//
//                             var selectedMedData = medicineList.firstWhere(
//                                     (doc) => doc.id == selectedMedicineId);
//
//                             addMedicine({
//                               "id": selectedMedicineId,
//                               "name": selectedMedData['name'],
//                               "quantity": selectedMedData['quantity'],
//                               "price": selectedMedData['price'],
//                             });
//                           },
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 // Medicine List Display
//                 Text("Medicines List:", style: TextStyle(
//                     fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 10),
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   itemCount: medicines.length,
//                   itemBuilder: (context, index) {
//                     final medicine = medicines[index];
//                     return Card(
//                       child: ListTile(
//                         title: Text(
//                             "${medicine['medicine']} - ${medicine['quantity']} pcs"),
//                         subtitle: Text("Price: ${medicine['price']}"),
//                       ),
//                     );
//                   },
//                 ),
//
//                 const SizedBox(height: 20),
//                 // Total Price Display
//                 Text(
//                   "Total Price: ${totalPrice.toStringAsFixed(2)}",
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 // Save Bill Button
//                 CustomButton(
//                   text: "Save Bill",
//                   onPressed: saveBillToFirestore,
//                 ),
//
//                 CustomButton(
//                   text: "Print",
//                   onPressed: generateAndDownloadPDF,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
