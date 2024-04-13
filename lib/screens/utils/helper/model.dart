
class placeModel {

  String image;
  String title;
  String desc;
  String Timer;
  List<bool> starStates;
  List<String>? ingredient;
  List<String>? instruction;

  placeModel(
      this.image, this.title, this.desc, this.Timer, this.starStates,
      {
        this.ingredient, this.instruction,
      } );
}