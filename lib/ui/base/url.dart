//实用网址  https://www.helplib.com/GitHub/article_154872

const BASE_URL = "http://api.zhuishushenqi.com";
// ======== 分类部分 =========
//1. 获取所有分类
// http://api.zhuishushenqi.com/cats/lv2/statistics
const BOOK_CATEGORIES_URL = "/cats/lv2/statistics";

//2. 获取排行榜类型
// http://api.zhuishushenqi.com/ranking/gender
const RANK_URL = "/ranking/gender";

//3. 获取排行榜小说 - 由第二步取的id
//http://api.zhuishushenqi.com/ranking/54d43437d47d13ff21cad58b
const RANK_INFO_URL = "/ranking/";

//4. 获取分类下小类别 (作用不大)
// http://api.zhuishushenqi.com/cats/lv2

//5. 根据分类获取小说列表
// https://api.zhuishushenqi.com/book/by-categories?gender=male&type=hot&major=%E5%A5%87%E5%B9%BB&minor=&start=0&limit=20

//6. 获取小说信息
// http://api.zhuishushenqi.com/book/548d9c17eb0337ee6df738f5

//7. 获取短评
// http://api.zhuishushenqi.com/post/short-review?book=5ba4beb11709700e14d9fad5&limit=3&total=true&sortType=hottest
const SHORT_REVIEW_URL = "/post/short-review";

//8. 获取长评
// http://api.zhuishushenqi.com/post/review/best-by-book?book=5ba4beb11709700e14d9fad5
const REVIEW_URL = "/post/review/best-by-book";

//9. 获取作者全部书籍
// http://api.zhuishushenqi.com/book/accurate-search?author="辰东"
const ACCURATE_SEARCH_URL = "/book/accurate-search";

//10. 获取书籍相关
// http://api.zhuishushenqi.com/book/5948c17d031fdaa005680400/recommend

//11. 推荐书单
// http://api.zhuishushenqi.com/book-list/5ba4beb11709700e14d9fad5/recommend?limit=2

//12. 编辑推荐
// http://api.zhuishushenqi.com/books/5948c17d031fdaa005680400/editor-comments?n=1

//13. 头像
// http://statics.zhuishushenqi.com{头像地址}

//==============阅读器部分======================
// 1. 混合源
// http://api.zhuishushenqi.com/atoc?view=summary&book=548d9c17eb0337ee6df738f5

// 2. 获取章节 (id 对应上面的源id)
// http://api.zhuishushenqi.com/atoc/568fef99adb27bfb4b3a58dc?view=chapters

// 3. 获取章节（默认官方源，传书籍id）
// http://api.zhuishushenqi.com/mix-atoc/50bff3ec209793513100001c?view=chapters

// 4. 获取具体内容 (chapter/ 后接的是章节后的link)
// http://chapterup.zhuishushenqi.com/chapter/http://vip.zhuishushenqi.com/chapter/5817f1161bb2ca566b0a5973?cv=1481275033588

// ==================书架部分===========================
// 1. 书籍的最后章节
// http://api.zhuishushenqi.com/book?view=updated&id=531169b3173bfacb4904ca67,592fe687c60e3c4926b040ca


//==============搜索部分=========================
// 1.搜索热词
// http://api.zhuishushenqi.com/book/search-hotwords

// 2. 自动补充
// http://api.zhuishushenqi.com/book/auto-suggest?query=%E8%BE%B0

// 3. 搜索热门书籍
//  http://api.zhuishushenqi.com/book/hot-word

// 4. 搜索
// http://api.zhuishushenqi.com/book/fuzzy-search?query=%E6%96%97%E7%BD%97

// http://api.zhuishushenqi.com/post/total-count?books=5816b415b06d1d32157790b1

//==============书单=================
//1. 热门推特
// https://api.zhuishushenqi.com/user/twitter/hottweets?pageSize=2

// https://api.zhuishushenqi.com/book/593ca0e6aeed91706d89acfc?t=0&useNewCat=true

//书单
// sort: (collectorCount|created),
// duration: (last-seven-days|all),
// gender: (male|female)
//http://api.zhuishushenqi.com/book-list?gender=male&tag=言情

//书单详情
// http://api.zhuishushenqi.com/book-list/:bookId


//=================评论=====================
//1. 最佳评论
// http://api.zhuishushenqi.com/post/5a237bc692126778194119a5/comment/best


//2. 评论主体
// http://api.zhuishushenqi.com/post/review/5a237bc692126778194119a5

//3.评论内部评论
// http://api.zhuishushenqi.com/post/review/5a237bc692126778194119a5/comment?start=0&limit=30

// 4.讨论排序
// http://api.zhuishushenqi.com/post/by-book?book=59ba0dbb017336e411085a4e&sort=created&type=normal,vote&start=0&limit=20

// 5.讨论最近评论
// http://api.zhuishushenqi.com/post/5c73b39e98176801670801d4/comment/best

// 6.讨论评论列表
// http://api.zhuishushenqi.com/post/5c73b39e98176801670801d4/comment?start=0&limit=30

// 7.讨论评论主体
// http://api.zhuishushenqi.com/post/5c73b39e98176801670801d4?keepImage=1