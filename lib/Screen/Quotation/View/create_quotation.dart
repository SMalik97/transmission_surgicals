import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart' as getX;

class CreateQuotation extends StatefulWidget {
  const CreateQuotation({Key? key}) : super(key: key);

  @override
  State<CreateQuotation> createState() => _CreateQuotationState();
}

class _CreateQuotationState extends State<CreateQuotation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 45,
            color: Color(0xff004d4d),
            child: Row(
              children: [
                SizedBox(width: 15,),
                Text("Generate Quotation", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 18),),


                SizedBox(width: 20,),


                InkWell(
                  onTap: (){

                  },
                  child: Container(
                    height: 30,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.blue
                    ),
                    child: Center(child: Text("General Quotation", style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)),
                  ),
                ),

                SizedBox(width: 20,),

                InkWell(
                  onTap: (){

                  },
                  child: Container(
                    height: 30,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.blue
                    ),
                    child: Center(child: Text("Quotation with Image", style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)),
                  ),
                ),


                Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(width: 15,),
                          Container(
                            height: 30,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: Color(0xff00802b)
                            ),
                            child: Center(child: Text("Download Invoice", style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)),
                          ),
                        SizedBox(width: 25,),
                        InkWell(
                          onTap: (){
                            // if(getX.Get.parameters['id'] == null){
                            //   getX.Get.offAndToNamed("/create-invoice");
                            // }else{
                            //   getX.Get.offAndToNamed("/create-invoice?purpose=$purpose&id=$invoice_id",);
                            // }
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
                        SizedBox(width: 15,),
                        InkWell(
                          onTap: (){
                            getX.Get.back();
                          },
                          child: Container(
                            width: 30, height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Colors.red,
                            ),
                            child: Icon(Icons.close, color: Colors.white, size: 18,),
                          ),
                        ),
                      ],
                    )
                ),
                SizedBox(width: 15,)
              ],
            ),
          ),
          createGenerateQuotation()
        ],
      ),
    );
  }



  Widget createGenerateQuotation(){
    return Column(
      children: [
        SizedBox(height: 10,),
        Container(
          width: 850,
          height: 500,
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/logo/logo.png", width: 150, height: 150,),
                  SizedBox(width: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Transmission Surgicals", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.blue),),
                      Text("333 J.C. Bose Road, PallyShree\nSodepur, Kolkata - 700110 \nPhone : +91 0333335980722 / 7278360630 / 9836947573\nEmail : surgicaltrans@gmail.com",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 12,color: Colors.redAccent),),
                    ],
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Divider(color: Colors.grey, thickness: 1,  height: 10),
              ),

              SizedBox(height: 10,),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: "Type Quotation title here"
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black
                        ),
                      ),
                    )
                  ],
                ),
              )

            ],
          ),
        ),
      ],
    );
  }


}
