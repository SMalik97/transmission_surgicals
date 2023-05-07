import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Products extends StatefulWidget {
  const Products({Key? key}) : super(key: key);

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
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
                                                        Container(
                                                          width: 30,height: 30,
                                                            decoration: BoxDecoration(
                                                              color: Colors.red.withOpacity(0.2),
                                                              borderRadius: BorderRadius.circular(2)
                                                            ),
                                                            child: Center(child: Icon(Icons.close, size: 20, color: Colors.red,))),
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
                                                            Container(
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
                                                            SizedBox(height: 10,),
                                                            Expanded(
                                                              child: ListView.builder(
                                                                shrinkWrap: true,
                                                                  itemCount: 5,
                                                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                                                  itemBuilder: (context,index){
                                                                   return Container(
                                                                     color: Colors.white,
                                                                     margin: EdgeInsets.symmetric(vertical: 5),
                                                                     height: 80,
                                                                     child: Stack(
                                                                       alignment: Alignment.topRight,
                                                                       children: [
                                                                         Row(
                                                                           mainAxisAlignment: MainAxisAlignment.end,
                                                                           children: [
                                                                             Container(
                                                                               width: 20,height: 20,
                                                                                 decoration: BoxDecoration(
                                                                                   color: Colors.red.withOpacity(0.3),
                                                                                   shape: BoxShape.circle
                                                                                 ),
                                                                                 child: Center(child: Icon(Icons.close, color: Colors.red, size: 16,))
                                                                             )
                                                                           ],
                                                                         ),
                                                                         Image.asset("assets/image/9712.png", fit: BoxFit.fill,),
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
                                                                    child: Image.asset("assets/image/9712.png"),
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
                                                                      onPressed: (){},
                                                                      child: Center(child: Padding(
                                                                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                                                                        child: Text("Add this Product", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),),
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
                            // fetch_challan_list();
                            // setState(() {
                            //   isListLoading=true;
                            //   isChallanLoading=false;
                            //   selectedIndex=0;
                            //   selectedChallanId="";
                            // });
                            Fluttertoast.showToast(
                                msg: "Refreshing...",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM_RIGHT,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                webBgColor: "linear-gradient(to right, #1da241, #1da241)",
                                fontSize: 16.0
                            );
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
              child: Container(
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
                  itemCount: 5,

                  itemBuilder: (context, index){
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5)
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
}
