class PhyImgModel {
  String imageMember='';
  String imageShop='';
  String imageItem='';



  PhyImgModel(this.imageMember, this.imageShop, this.imageItem);
  PhyImgModel.fromJson(Map<String, dynamic> json){
    imageMember = json['imageMember'];
    imageShop = json['imageShop'];    
    imageItem = json['imageItem']; 
  }

  Map<String, dynamic> toJson() {
    final data =  Map<String, dynamic>();
    data['imageMember'] = this.imageMember;   
    data['imageShop'] = this.imageShop; 
    data['imageItem'] = this.imageItem; 
    return data;
  }

}