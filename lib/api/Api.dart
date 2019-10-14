class Api {
  static final String host =
      "http://www.doclever.cn:8090/mock/5d9078ed4a9da91cd653f06f/api/v1";
  // static final String host = "https://www.oschina.net";
  // 资讯列表
  static final String newsList =
      "http://www.doclever.cn:8090/mock/5d9078ed4a9da91cd653f06f/api/v1/coupons";
  // static final String newsList = "http://osc.yubo.me/news/list";
  // 资讯列表
  static final String couponCode =
      "http://www.doclever.cn:8090/mock/5d9078ed4a9da91cd653f06f/api/v1/get_coupon_code";
  // 资讯详情
  static final String newsDetail = host + "/action/openapi/news_detail";

  // 动弹列表
  static final String tweetsList = host + "/action/openapi/tweet_list";

  // 评论列表
  static final String commentList = host + "/action/openapi/comment_list";

  // 评论回复
  static final String commentReply = host + "/action/openapi/comment_reply";

  // 获取用户信息
  static final String userInfo = host + "/action/openapi/user";

  // 发布动弹
  static final String pubTweet = host + "/action/openapi/tweet_pub";

  // 添加到小黑屋
  static final String addToBlack = "http://osc.yubo.me/black/add";

  // 查询小黑屋
  static final String queryBlack = "http://osc.yubo.me/black/query";

  // 从小黑屋中删除
  static final String deleteBlack = "http://osc.yubo.me/black/delete";

  // 开源活动
  static final String eventList = "http://osc.yubo.me/events/";
}
