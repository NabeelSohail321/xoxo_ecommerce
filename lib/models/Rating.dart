class Rating{
  String pid,ratings,users;

  Rating(this.pid, this.ratings, this.users);

  Map<dynamic, dynamic> tomap(){
    return{
      'pid': pid,
      'rating': ratings,
      'users': users
    };
  }

}