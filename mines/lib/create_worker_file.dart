import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CreateWorkerPage extends StatefulWidget {
  const CreateWorkerPage({super.key});

  @override
  _CreateWorkerPageState createState() => _CreateWorkerPageState();
}

class _CreateWorkerPageState extends State<CreateWorkerPage> {
  final ImagePicker picker = ImagePicker();
  File? selectedImage;

  // UPDATE WITH YOUR SYSTEM IP
  final String baseUrl = "http://10.220.32.211:8091/api/worker";

  // Controllers
  final workerId = TextEditingController();
  final name = TextEditingController();
  final role = TextEditingController();
  final phone = TextEditingController();
  final dob = TextEditingController();
  final shift = TextEditingController();
  final blood = TextEditingController();
  final address = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  bool loading = false;

  // PICK IMAGE
  pickImage() async {
    final img = await picker.pickImage(source: ImageSource.camera);
    if(img!=null) setState(()=>selectedImage=File(img.path));
  }

  // SAVE WORKER + IMAGE TOGETHER
  saveWorker() async {
    if(selectedImage==null){ msg("⚠ Select Image First"); return; }
    if(password.text!=confirm.text){ msg("❗ Password mismatch"); return; }

    setState(()=>loading=true);

    var req = http.MultipartRequest("POST", Uri.parse("$baseUrl/create-with-image"));
    req.fields.addAll({
      "workerId": workerId.text,
      "name": name.text,
      "role": role.text,
      "phone": phone.text,
      "dob": dob.text,
      "shift": shift.text,
      "bloodGroup": blood.text,
      "address": address.text,
      "password": password.text,
    });

    req.files.add(await http.MultipartFile.fromPath("image", selectedImage!.path));
    var res = await req.send();
    setState(()=>loading=false);

    if(res.statusCode==200){ msg("✅ Worker Created Successfully"); clear(); }
    else{ msg("❌ Upload Failed"); }
  }

  clear(){
    workerId.clear(); name.clear(); role.clear(); phone.clear(); dob.clear();
    shift.clear(); blood.clear(); address.clear(); password.clear();
    confirm.clear(); selectedImage=null; setState((){});
  }

  msg(t)=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(t)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCBE7EA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            const SizedBox(height:10),
            const Text("Create Workers",
                style:TextStyle(fontSize:26,fontWeight:FontWeight.bold)),

            const SizedBox(height:15),

            /// MAIN CARD UI
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF577B8D),
                borderRadius: BorderRadius.circular(35),
              ),

              child: Column(children:[

                /// 🔥 TOP ROW — IMAGE + 2 FIELDS
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// LEFT IMAGE
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        width:140, height:170,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFC75E),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child:selectedImage==null
                            ? const Icon(Icons.person,size:85,color:Colors.white)
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.file(selectedImage!, fit: BoxFit.cover),
                        ),
                      ),
                    ),

                    const SizedBox(width:18),

                    /// Right Side Inputs
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          fieldTitle("Worker ID"),
                          fieldBox(workerId),
                          const SizedBox(height:10),
                          fieldTitle("Name"),
                          fieldBox(name),
                        ],
                      ),
                    )

                  ],
                ),

                const SizedBox(height:20),

                /// Role + Phone
                rowInput("Role", role , "Phone Number", phone),

                const SizedBox(height:12),

                /// DOB + Shift
                rowInput("DOB", dob , "Shift", shift),

                const SizedBox(height:12),

                /// Blood Group + Address
                rowInput("Blood Group", blood , "Address", address),

                const SizedBox(height:12),

                /// Password + Confirm
                rowInput("Password", password, "Confirm Password", confirm, pass:true),

                const SizedBox(height:15),

                /// Already have account? Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Already have an account?",style:TextStyle(color:Colors.white70,fontSize:14)),
                    Text("Log in",style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold)),
                  ],
                ),

                const SizedBox(height:20),

                /// Save Button
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:loading?null:saveWorker,
                    style:ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEFC75E),
                      padding: const EdgeInsets.all(14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child:loading
                        ? const CircularProgressIndicator(color:Colors.black)
                        : const Text("Create Account",
                        style:TextStyle(fontSize:20,color:Colors.black,fontWeight:FontWeight.bold)),
                  ),
                )

              ]),
            ),

            const SizedBox(height:25),
          ],
        ),
      ),
    );
  }

  /// ======= UI Components =======
  Widget rowInput(String t1, TextEditingController c1 , String t2, TextEditingController c2,{bool pass=false}) {
    return Row(
      children: [
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[fieldTitle(t1),fieldBox(c1,isPass:pass)])),
        const SizedBox(width:10),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[fieldTitle(t2),fieldBox(c2,isPass:pass)])),
      ],
    );
  }

  Widget fieldTitle(txt)=>Padding(
    padding: const EdgeInsets.only(left:4,bottom:4),
    child:Text(txt,style:const TextStyle(color:Colors.white,fontSize:16,fontWeight:FontWeight.w600)),
  );

  Widget fieldBox(TextEditingController c,{bool isPass=false})=>TextField(
    controller:c,
    obscureText:isPass,
    decoration:InputDecoration(
        filled:true,fillColor:Colors.white,
        border:OutlineInputBorder(borderRadius:BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical:12,horizontal:10)
    ),
  );
}
