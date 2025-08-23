class Skill {
  int? id;
  String? skill;

  Skill({this.id, this.skill});

  Skill.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    skill = json['skill'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['skill'] = skill;
    return data;
  }
}
