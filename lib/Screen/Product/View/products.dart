import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart' as getX;
import 'package:motion_toast/motion_toast.dart';
import '../../../Utils/urls.dart';
import '../Model/product_model.dart';
import '../Model/select_image_list.dart';

class Products extends StatefulWidget {
  const Products({Key? key}) : super(key: key);

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {

  List<SelectImageList> selected_image_list=[];
  List<ProductModel> product_list=[];
  final ImagePicker _picker = ImagePicker();

  final product_name_control=TextEditingController();
  final product_price_control=TextEditingController();
  final product_description_control=TextEditingController();

  bool isProductFetching=true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 40,
            width: double.infinity,
            color: Color(0xff004d4d),
            child: Row(
              children: [
                SizedBox(width: 15,),
                Text("Products & Services", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 18),),
                Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () async {
                            showAddDialog();

                          },
                          child: Container(
                            height: 30,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: Color(0xff00802b)
                            ),
                            child: Center(child: Text("Add New Product", style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)),
                          ),
                        ),
                        SizedBox(width: 25,),
                        InkWell(
                          onTap: (){

                            setState(() {
                              product_list.clear();
                              isProductFetching=true;
                            });

                            fetchAllProduct();
                            MotionToast.success(
                              title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
                              description:  Text("Refreshing..."),
                            ).show(context);

                          },
                          child: Container(
                            width: 30, height: 30,
                            decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle
                            ),
                            child: Icon(Icons.refresh, color: Colors.white, size: 18,),
                          ),
                        ),
                      ],
                    )
                ),
                SizedBox(width: 15,)
              ],
            ),
          ),
          Expanded(
              child: isProductFetching==true ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 25, height: 25,
                      child: CircularProgressIndicator(color: Colors.blue,),
                    ),
                    SizedBox(height: 10,),
                    Text("Getting Product List ..", style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w600),)
                  ],
                ),
              ) :Container(
                color: Color(0xffb3b3ff),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1/1,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shrinkWrap: true,
                  itemCount: product_list.length,
                  itemBuilder: (context, index){
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Container(
                                padding: EdgeInsets.all(5),
                                color: Colors.grey.shade200,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(child: Image.network(product_image_base_path+product_list[index].images![0].imageName.toString(),alignment: Alignment.center,)),
                                    ],
                                  )
                              )
                          ),
                          Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 5,),
                                    Text(product_list[index].productName.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),maxLines: 1,),
                                    SizedBox(height: 5,),
                                    Text("Price : "+product_list[index].productName.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),),
                                    SizedBox(height: 5,),
                                    Text(product_list[index].productDescription.toString(), style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black,overflow: TextOverflow.fade),softWrap:false,maxLines: 3),
                                   Expanded(
                                       child: Column(
                                         mainAxisAlignment: MainAxisAlignment.end,
                                         children: [
                                           Divider(height: 15,thickness: 0.5,color: Colors.grey,),
                                           Row(
                                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                             children: [
                                               Container(
                                                 width: 80,
                                                 height: 28,
                                                 decoration: BoxDecoration(
                                                     color: Colors.blue,
                                                     borderRadius: BorderRadius.circular(5)
                                                 ),
                                                 child: Center(child: Text("Edit", style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),)),
                                               ),
                                               InkWell(
                                                 onTap: (){
                                                   deleteProduct(index);
                                                 },
                                                 child: Container(
                                                   width: 80,
                                                   height: 28,
                                                   decoration: BoxDecoration(
                                                       color: Colors.red,
                                                       borderRadius: BorderRadius.circular(5)
                                                   ),
                                                   child: Center(child: Text("Delete", style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),)),
                                                 ),
                                               ),
                                             ],
                                           ),
                                           SizedBox(height: 8,)
                                         ],
                                       )
                                   )
                                  ],
                                ),
                              )
                          ),
                        ],
                      ),
                    );
                  },

                ),
              )
          )
        ],
      ),
    );
  }


  @override
  void initState() {
    fetchAllProduct();
    super.initState();
  }

  showAddDialog(){
    int? selectedIndex;
    bool isUpdating =false;
    Dialog pDialog=Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      insetPadding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.2),
      child: StatefulBuilder(
        builder: (context,setState) {
          return Wrap(
            children: [
              Container(
                width: MediaQuery.of(context).size.width*0.6,
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      height: 40,
                      width: double.infinity,
                      color: Colors.blueGrey,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Text("Add New Product", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),),
                            Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: (){
                                        product_name_control.clear();
                                        product_price_control.clear();
                                        product_description_control.clear();
                                        selected_image_list.clear();
                                        getX.Get.back();
                                      },
                                      child: Container(
                                          width: 30,height: 30,
                                          decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(2)
                                          ),
                                          child: Center(child: Icon(Icons.close, size: 20, color: Colors.red,))),
                                    ),
                                  ],
                                )
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 100,
                                height: 400,
                                color: Colors.grey.withOpacity(0.2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50,);
                                        Uint8List file = await pickedFile!.readAsBytes();
                                        setState((){
                                          SelectImageList a =SelectImageList(file: file, file_name: pickedFile.name.toString());
                                          selected_image_list.add(a);
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(2)
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.add, color: Colors.blue,size: 14,),
                                            SizedBox(width: 5,),
                                            Text("Add Image", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500, fontSize: 12),)
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10,),
                                    Expanded(
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: selected_image_list.length,
                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                          itemBuilder: (context,index){
                                            return Container(
                                              color: Colors.white,
                                              margin: EdgeInsets.symmetric(vertical: 5),
                                              height: 80,
                                              child: Stack(
                                                alignment: Alignment.topRight,
                                                children: [
                                                  InkWell(
                                                      onTap: (){
                                                        setState((){
                                                          selectedIndex=index;
                                                        });
                                                      },
                                                      child: Image.memory(selected_image_list[index].file!,alignment: Alignment.center,width: 80,height: 80,)
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      InkWell(
                                                        onTap: (){
                                                          setState((){
                                                            selected_image_list.removeAt(index);
                                                            selectedIndex=null;
                                                          });
                                                        },
                                                        child: Container(
                                                            width: 20,height: 20,
                                                            decoration: BoxDecoration(
                                                                color: Colors.red.withOpacity(0.3),
                                                                shape: BoxShape.circle
                                                            ),
                                                            child: Center(child: Icon(Icons.close, color: Colors.red, size: 16,))
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(width: 10,),

                              Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 300,
                                            height: 300,
                                            child: selectedIndex==null? Container():Image.memory(selected_image_list[selectedIndex!].file!),
                                          ),
                                          SizedBox(width: 15,),
                                          Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text("Product Name", style: TextStyle(fontWeight: FontWeight.w600,color: Colors.blue.shade700, fontSize: 14),),
                                                  SizedBox(height: 5,),
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 5,vertical: 3),
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(3),
                                                        border: Border.all(color: Colors.black87, width: 1)
                                                    ),
                                                    child: TextField(
                                                      controller: product_name_control,
                                                      decoration: InputDecoration(
                                                          isDense: true,
                                                          border: InputBorder.none
                                                      ),
                                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                                                    ),
                                                  ),

                                                  SizedBox(height: 15,),

                                                  Text("Product Price", style: TextStyle(fontWeight: FontWeight.w600,color: Colors.blue.shade700, fontSize: 14),),
                                                  SizedBox(height: 5,),
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 5,vertical: 3),
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(3),
                                                        border: Border.all(color: Colors.black87, width: 1)
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Text("Rs. ",style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),),
                                                        Expanded(
                                                          child: TextField(
                                                            controller: product_price_control,
                                                            decoration: InputDecoration(
                                                                isDense: true,
                                                                border: InputBorder.none
                                                            ),
                                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  SizedBox(height: 15,),

                                                  Text("Product Description", style: TextStyle(fontWeight: FontWeight.w600,color: Colors.blue.shade700, fontSize: 14),),
                                                  SizedBox(height: 5,),
                                                  Container(
                                                    constraints: BoxConstraints(
                                                      minHeight: 160,
                                                    ),
                                                    padding: EdgeInsets.symmetric(horizontal: 5,vertical: 3),
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(3),
                                                        border: Border.all(color: Colors.black87, width: 1)
                                                    ),
                                                    child: TextField(
                                                      controller: product_description_control,
                                                      decoration: InputDecoration(
                                                          isDense: true,
                                                          border: InputBorder.none
                                                      ),
                                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                                                    ),
                                                  )
                                                ],
                                              )
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 50,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue
                                              ),
                                              onPressed: isUpdating==true? null :() async {
                                                setState((){
                                                  isUpdating=true;
                                                });
                                                var uri = Uri.parse(add_new_product);
                                                var request = MultipartRequest("POST", uri);
                                                request.fields["product_name"] = product_name_control.text;
                                                request.fields["product_price"] = product_price_control.text;
                                                request.fields["product_details"] = product_description_control.text;
                                                for(int i=0; i<selected_image_list.length; i++){
                                                  var multipartFile = await MultipartFile.fromBytes("userfile[]", selected_image_list[i].file!, filename: selected_image_list[i].file_name);
                                                  request.files.add(multipartFile);
                                                }
                                                StreamedResponse response = await request.send();
                                                if(response.statusCode == 200){
                                                  response.stream.bytesToString().asStream().listen((event){
                                                    var jsonData = jsonDecode(event);
                                                    if (jsonData['status'] == "success") {

                                                      MotionToast.success(
                                                        title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
                                                        description:  Text("Product updated!"),
                                                      ).show(context);
                                                      product_name_control.clear();
                                                      product_price_control.clear();
                                                      product_description_control.clear();
                                                      selected_image_list.clear();
                                                      getX.Get.back();
                                                    }
                                                  });

                                                }else{
                                                  MotionToast.error(
                                                    title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
                                                    description:  Text("Some error has occurred"),
                                                  ).show(context);
                                                }

                                                setState((){
                                                  isUpdating=false;
                                                });

                                              },
                                              child: Center(child: Padding(
                                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                                                child: Text(isUpdating==true ? "Updating ..." :"Add this Product", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),),
                                              ))),
                                        ],
                                      ),
                                      SizedBox(height: 50,),
                                    ],
                                  )
                              )
                            ],
                          )
                        ],
                      ),
                    )

                  ],
                ),
              ),
            ],
          );
        },

      ),
    );
    showDialog(context: context, builder: (context)=>pDialog);
  }


  fetchAllProduct() async {
    var url = Uri.parse(fetch_all_product);
    Response response = await post(url,);
    if(response.statusCode==200){
      String myData = response.body;
      var jsonData=jsonDecode(myData);
      // if(jsonData['status']=="success"){
        product_list.clear();
        jsonData.forEach((jsonResponse) {
          ProductModel obj = new ProductModel.fromJson(jsonResponse);
          setState(() {
            product_list.add(obj);
          });
        });

      }
    setState(() {
      isProductFetching=false;
    });
  }


  deleteProduct(int index){
    Dialog delete = Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Wrap(
        children: [
          Container(
            width: 320,
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(height: 15,),
                Text("Delete?", style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),),
                SizedBox(height: 15,),
                Text("Are you sure you want to delete this product?",style: TextStyle(color: Colors.black,fontSize: 14,fontWeight: FontWeight.w500)),
                SizedBox(height: 25,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: (){
                        getX.Get.back();
                      },
                      child: Container(
                        height: 32,
                        width: 80,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.red, width: 0.7),
                            color: Colors.red.withOpacity(0.1)
                        ),
                        child: Center(child: Text("Cancel", style: TextStyle(color: Colors.red,fontSize: 14,fontWeight: FontWeight.w600))),
                      ),
                    ),

                    InkWell(
                      onTap: (){
                        setState(() {
                          deleteProductApi(product_list[index].productId.toString());
                          product_list.removeAt(index);
                        });
                        getX.Get.back();
                      },
                      child: Container(
                        height: 32,
                        width: 80,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.blue, width: 0.7),
                            color: Colors.blue.withOpacity(0.1)
                        ),
                        child: Center(child: Text("Delete", style: TextStyle(color: Colors.blue,fontSize: 14,fontWeight: FontWeight.w600))),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 15,),
              ],
            ),
          )
        ],
      ),
    );
    showDialog(context: context, builder: (context)=>delete);
  }


  deleteProductApi(product_id) async {
    var url = Uri.parse(delete_product);
    Map<String, String> body = {"product_id": product_id};
    Response response = await post(url, body: body);
    if(response.statusCode==200){
      String myData = response.body;
      var jsonData=jsonDecode(myData);
      if(jsonData['status']=="success"){
        setState(() {});
      }else{
        MotionToast.error(
          title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
          description:  Text("Error while loading"),
        ).show(context);

      }
    }else{
      MotionToast.error(
        title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
        description:  Text("Some error has occurred"),
      ).show(context);

    }
  }

}
