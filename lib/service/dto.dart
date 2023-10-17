class QuotesDto {
  String? text;
  String? author;

  QuotesDto.fromJson(Map<String, dynamic> value)
      : text = value["text"],
        author = value["author"];
}