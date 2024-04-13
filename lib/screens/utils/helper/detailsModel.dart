class DetailsModel {
  final String recipeName;
  final String category;
  final String area;
  final List<String> ingredients;
  final List<String> instructions;
  final String image;
  final String videoLink;

  DetailsModel({
    required this.recipeName,
    required this.category,
    required this.area,
    required this.ingredients,
    required this.instructions,
    required this.image,
    required this.videoLink,
  });

  factory DetailsModel.fromJson(Map<String, dynamic> json) {
    List<String> ingredients = [];
    List<String> instructions = [];
    for (int i = 1; i <= 20; i++) {
      final String? ingredient = json['strIngredient$i'];
      if (ingredient != null && ingredient.isNotEmpty) {
        ingredients.add(ingredient);
      } else {
        break;
      }
    }

    final String instructionsString = json['strInstructions'] ?? '';
    if (instructionsString.isNotEmpty) {
      instructions = instructionsString.split('\n');
    }

    return DetailsModel(
      recipeName: json['strMeal'] ?? '',
      category: json['strCategory'] ?? '',
      area: json['strArea'] ?? '',
      ingredients: ingredients,
      instructions: instructions,
      image: json['strMealThumb'] ?? '',
      videoLink: json['strYoutube'] ?? '',
    );
  }
}
