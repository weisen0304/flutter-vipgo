/**
 * Author: Weisen
 * Date: 2019-10-14 20:44:22
 * Github: https://github.com/weisen0304
 */
class Api {
  static final String host = "http://localhost:7001";
  // 商品列表
  static final String newsList = "$host/api/v1/coupons";
  // 优惠券码
  static final String couponCode =
      "http://www.doclever.cn:8090/mock/5d9078ed4a9da91cd653f06f/api/v1/get_coupon_code";
  // 交易记录列表
  static final String dealsList =
      "http://www.doclever.cn:8090/mock/5d9078ed4a9da91cd653f06f/api/v1/deals";
  // 文章列表
  static final String articlesList =
      "http://www.doclever.cn:8090/mock/5d9078ed4a9da91cd653f06f/api/v1/articles";
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
