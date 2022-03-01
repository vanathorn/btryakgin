class PopulaItem {
  String foodid='';
  String ftypeid='';
  String name='';
  String fdetail='';
  String fimage='';

  PopulaItem({
    this.foodid,
    this.ftypeid,
    this.name,
    this.fdetail,
    this.fimage}
  );

  PopulaItem.fromJson(Map<String, dynamic> json) {
    foodid = json['foodid'];
    ftypeid = json['ftypeid'];
    name = json['name'];
    fdetail = json['fdetail'];
    fimage = json['fimage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['foodid'] = this.foodid;
    data['ftypeid'] = this.ftypeid;
    data['name'] = this.name;
    data['fdetail'] = this.fdetail;
    data['fimage'] = this.fimage;
    return data;
  }
}
