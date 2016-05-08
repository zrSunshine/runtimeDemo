runtime一致蒙着一层神秘的面纱,在面试中,90%的技术都会问道相关的问题,目的为了考察OC中学习的深度.这里是我们自己学习runtime的一些理解,觉得有用的朋友可以借鉴下,大神们路过就好

###列举几个常用的运行时方法

	#import <objc/runtime.h>

	// 获得某个类的类方法
	 Method class_getClassMethod(<#__unsafe_unretained Class cls#>, <#SEL name#>)

    // 获得某个类的对象方法
    Method class_getInstanceMethod(<#__unsafe_unretained Class cls#>, <#SEL name#>)

    // 方法交换
    void method_exchangeImplementations(<#Method m1#>, <#Method m2#>)
    
    // 拷贝某个类的所有成员变量
    class_copyIvarList(<#__unsafe_unretained Class cls#>, <#unsigned int *outCount#>)

    // 设置关联对象
    objc_setAssociatedObject(<#id object#>, <#const void *key#>, <#id value#>, <#objc_AssociationPolicy policy#>)

    // 获取关联对象
    objc_getAssociatedObject(<#id object#>, <#const void *key#>)

    // 给某个对象发送某个消息
    void objc_msgSend(void /* id self, SEL op, ... */ )

###1. runtime是一套纯C语言的API(纯C语言的库)

###2. 利用运行时,可以做很多底层的操作,比如:

#####获得某个类的所有成员方法，所有成员变量


	     ///  获的某个类的所有成员变量

	    ///  参数1:要获取的类
	    ///  参数2:成员变量的个数 (这里需要传一个`unsigned int`类型变量地址)
	    ///
	    ///  @return Ivar * (返回一个`Ivar *`类型的指针,里面装满了这个类的成员变量,类似一个数组,但不是数组,应该说它是以个结构体指针)
	    
	     Ivar *ivars = class_copyIvarList(__unsafe_unretained Class cls, unsigned int *outCount);
	    
		* 方法描述:可以这样来理解这个方,拷贝某个类`参数1`的成员变量列表,当这个方法执行完时,我们可以得到这个类的所有成员变量个数保存在`unsigned int`类型的变量`参数2`中.返回一个`Ivar *`类型的指针,里面装满了这个类的成员变量.


####举例

* 案例一 
	
		给Person类定义三个属性
		
		@property (nonatomic,copy) NSString *name;
		@property (nonatomic,assign) CGFloat heiget;
		@property (nonatomic,assign) int age;

* 获取类的成员变量

	
		首先定义一个变量来保存成员变量个数
		unsigned int outCount = 0;
		    
	    Ivar *ivars = class_copyIvarList([Person class], &outCount);
	    
	    关于参数2为什么要传一个地址:有人可能会疑惑,来记录个数,传一个outCount不就行了,为什么要传&outCount,
	    如果,我们直接把变量outCount传进去,首先会有警告
	    其次,直接传outCount就成了值传递,等于将 0 这个值传到了函数中,执行完函数后,外面记录成员变量总数的变量值是不会改变的.
	    因此,这里将outCount的地址穿进去,在函数执行过程中通过&outCount地址访问外部变量,修改变量的值并保存起来


 * 遍历所有成员变量
	    
	    for (int i = 0; i < outCount; i++) {
	        // 逐个取出
	        Ivar ivar = ivars[i];
	        
	        const char *name = ivar_getName(ivar);
	        const char *type = ivar_getTypeEncoding(ivar);
	        ptrdiff_t offset = ivar_getOffset(ivar);
	        
	        NSLog(@"name:%s--type:%s--offset:%zd",name,type,offset);
	    }
	    
	    注意:这里当C语言函数中出现了(copy,,creat,retain,new等词语时,那么我们在程序最后都应该要释放资源)
	    
	    free(ivars); // 释放资源
	    
	   关于返回值Ivar *ivars: 我们说它并不是数组,但是怎么能想数组一样通过遍历来获得每个成员变量呢,而且它只是一个指针怎么代表所有成员变量呢 ?
	   首先,函数返回一个指向Ivar的指针,而ivars中保存着所有的成员变量,那么这个指针就指向了这些成员变量中的某一个,一般来说都是指向最前面的一个,那么
	   	当`i` == 0 时,指针指向第一个成员变量 (当前指向的值)
	   	当`i` == 1 时,指针会指向当前指向的下一值
		当`i` == 2 时,指针会指向当前指向的下下个值
		......以此类推
		
**函数说明**

* 获取成员变量的名称
	
		ivar_getName(Ivar v)
	
* 获取成员变量的类型	
	
		ivar_getTypeEncoding(Ivar v)
    
* 获取成员变量的基地址偏移字节

    	ivar_getOffset(Ivar v)
    	
    	
    	
    	
#####利用runtime,实现自动归档与自动解档

**案例二**
 
 * 需求描述:假如我们在开发中有很多个模型类,每个模型类中都有很多模型属性,那么,我们在归档和解档的时候是不是要写很多遍`encodeObject: forKey:`和`decodeObjectForKey:`,对自己技术来说没有什么提升,是浪费时间的.那么,这里介绍一种运用runtime的方式实现自动归档,解档的方法,只需要在模型中遵守`<NSCoding>`协议,实现下面两个方法就可以搞定
		
* 保存到文件中 (归档)

		- (void)encodeWithCoder:(NSCoder *)encoder {
		    
		    unsigned int outCount = 0;
		    // 获取类的所有成员变量
		    Ivar *ivars = class_copyIvarList([self class], &outCount);
		    // 逐个获取
		    for (int i = 0; i < outCount; i++) {
		        Ivar ivar = ivars[i];
		        
		        // ivar_getName(ivar)返回一个C语言的 `const char *`类型,我们需要转换成OC的字符串来进行归档
		        // C语言字符串转换成OC字符串
		        // @(ivar_getName(ivar)) 等价于 [NSString stringWithUTF8String:ivar_getName(ivar)];
		        // 获得成员变量名
		        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
		
		        // 利用KVC获取对应成员变量的值
		        id value = [self valueForKeyPath:key];
		        
		        // 根据key和value进行归档
		        [encoder encodeObject:value forKey:key];
		    }
		    // 释放
		    free(ivars);
		}



* 从文件中读取 (解档)

		- (instancetype)initWithCoder:(NSCoder *)decoder {
		
		    if (self = [super init]) {
		        
		        unsigned int outCount = 0;
		        // 获取类的所有成员变量
		        Ivar *ivars = class_copyIvarList([self class], &outCount);
		        // 逐个获取
		        for (int i = 0; i < outCount; i++) {
		            Ivar ivar = ivars[i];
		            
		            // 获取成员变量名
		            NSString *key = @(ivar_getName(ivar));
		            
		            // 解档
		            id value = [decoder decodeObjectForKey:key];
		            
		            // 这句代码就等于(decoder decode...ForKey:),给每个属性设置value
		            [self setValue:value forKeyPath:key];
		        }
		        // 释放
		        free(ivars);
		    }
		    return self;
		}

---

#####增加忽略属性方法

* 新增忽略属性

		// 假设需要归档的属性
		@property (nonatomic,copy) NSString *name;
		@property (nonatomic,assign) CGFloat heiget;
		@property (nonatomic,assign) double weight;
		@property (nonatomic,assign) int age;
		
		// 要忽略的属性
		@property (nonatomic,assign) int ignore1;
		@property (nonatomic,assign) int ignore2;
		@property (nonatomic,assign) int ignore3;
		
		

* 不需要归档的属性,我们可以当读写一个方法来记录

		///  不需要归档的属性
		- (NSArray *)ignoreNames {
		
		    return @[@"_ignore1",@"_ignore2",@"_ignore3"];
		}


* 从文件中读取(解档)

		- (instancetype)initWithCoder:(NSCoder *)decoder {
		
		    if (self = [super init]) {
		        
		        unsigned int outCount = 0;
		        // 获取类的所有成员变量
		        Ivar *ivars = class_copyIvarList([self class], &outCount);
		        // 逐个获取
		        for (int i = 0; i < outCount; i++) {
		            Ivar ivar = ivars[i];
		            
		            // C语言字符串转换成OC字符串
		            NSString *key = @(ivar_getName(ivar));
		            
		            // 忽略不需要解档的属性
	   **增加忽略** if ([[self ignoreNames] containsObject:key]) continue;
		            
		            // 解档
		            id value = [decoder decodeObjectForKey:key];
		            
		            // 这句代码就等于(decoder decode...ForKey:),给每个属性设置value
		            [self setValue:value forKeyPath:key];
		        }
		        // 释放
		        free(ivars);
		    }
		    return self;
		}


* 保存到文件中 (归档)

		- (void)encodeWithCoder:(NSCoder *)encoder {
		    
		    unsigned int outCount = 0;
		    // 获取类的所有成员变量
		    Ivar *ivars = class_copyIvarList([self class], &outCount);
		    // 逐个获取
		    for (int i = 0; i < outCount; i++) {
		        Ivar ivar = ivars[i];
		        
		        // C语言字符串转换成OC字符串
		        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
		        
		        // 忽略不需要归档的属性
	**增加忽略** if ([[self ignoreNames] containsObject:key]) continue;
		
		        // 利用KVC获取对应成员变量的值
		        id value = [self valueForKeyPath:key];
		        
		        // 根据key和value进行归档
		        [encoder encodeObject:value forKey:key];
		    }
		    // 释放资源
		    free(ivars);
		}


---


**补充:NSObject + Extension 抽取宏**

* 这里补充一个分类的方法变化不大,大家喜欢的也可以试试,灵活性会好一点
* 新增:在上面的基础上新添加`1.新增了子类可以归档父类属性实现`,`2.抽取一个单例宏方法`

* 首先创建一个NSObject的Category,自定义三个方法@interface NSObject (Extension)

		@interface NSObject (Extension)
		
		///  忽略方法
		- (NSArray *)ignoreNames;
		///  归档方法
		- (void)encode:(NSCoder *)encoder;
		///  解档方法
		- (void)decode:(NSCoder *)decoder;


* 实现@implementation NSObject (Extension)

		@implementation NSObject (Extension)
		
		
		///  从文件中读取 (解档)
		- (void)decode:(NSCoder *)decoder {
		
		     *********新增部分**********
		    Class currentClass = self.class;
		    // 如果当前类不是NSObject这个类,就实现归档
		    while (currentClass && currentClass != [NSObject class]) {
		    
		        unsigned int outCount = 0;
		        // 获取类的所有成员变量
		        Ivar *ivars = class_copyIvarList(currentClass, &outCount);
		        // 逐个获取
		        for (int i = 0; i < outCount; i++) {
		            Ivar ivar = ivars[i];
		            
		            // C语言字符串转换成OC字符串
		            NSString *key = @(ivar_getName(ivar));
		            
		            *********新增部分**********
		            // 判断调用的类中是否有要忽略的属性
		            if ([self respondsToSelector:@selector(ignoreNames)]) {
		                // 忽略不需要解档的属性
		                if ([[self ignoreNames] containsObject:key]) continue;
		            }
		            
		            // 解档
		            id value = [decoder decodeObjectForKey:key];
		            
		            // 这句代码就等于(decoder decode...ForKey:),给每个属性设置value
		            [self setValue:value forKeyPath:key];
		        }
		        // 释放
		        free(ivars);
		        // 重新赋值当前的类
		        currentClass = [currentClass superclass];
		    }
		}
		
		
			///  保存到文件中 (归档)
		- (void)encode:(NSCoder *)encoder {
		    
		    *******新增部分*******
		    Class currentClass = self.class;
		    // 如果当前类不是NSObject这个类,就实现归档
		    while (currentClass && currentClass != [NSObject class]) {

		        unsigned int outCount = 0;
		        // 获取类的所有成员变量
		        Ivar *ivars = class_copyIvarList(currentClass, &outCount);
		        // 逐个获取
		        for (int i = 0; i < outCount; i++) {
		            Ivar ivar = ivars[i];
		            
		            // C语言字符串转换成OC字符串
		            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
		            
		           *********新增部分**********
		            	// 判断调用的类中是否有要忽略的属性
		        		if ([self respondsToSelector:@selector(ignoreNames)]) {
		                // 忽略不需要解档的属性
		                if ([[self ignoreNames] containsObject:key]) continue;
		            }
		            
		            // 利用KVC获取对应成员变量的值
		            id value = [self valueForKeyPath:key];
		            
		            // 根据key和value进行归档
		            [encoder encodeObject:value forKey:key];
		        }
		        // 释放资源
		        free(ivars);
		        // 重新赋值当前的类
		        currentClass = [currentClass superclass];
		    }
		}


* 抽取宏

* 把归档和解档方法的实现抽取到一个宏文件中,最后我们只需要在要解归档的地方调用`CodeingImple`一句话搞定

		 #define CodeingImple \
		- (instancetype)initWithCoder:(NSCoder *)aDecoder { \
		    if (self = [super init]) { \
		        \
		        [self decode:aDecoder]; \
		    }   \
		    return self;    \
		}   \
		    \
		- (void)encodeWithCoder:(NSCoder *)aCoder { \
		    \
		    [self encode:aCoder];   \
		}
		注意:最后的位置不要加`\`


**小结**

		**子类也可以归档父类属性,重点就在这里**
		
		 Class currentClass = self.class;
		// 如果当前类不是NSObject这个类,就实现归档
		while (currentClass && currentClass != [NSObject class])
		
		首先获得当前对象的类,self.class
		然后用while循环来判断,当前类currentClass如果不是NSObject的情况下,才需要进行解归档操作,NSObject是最基类,它没有父类,如果判断是NSObject就表示不用再归档父类属性
		
		// 重新赋值当前的类
		currentClass = [currentClass superclass];
		程序执行到最后,重新给当前类赋值为它的父类,这样就可以持续循环找到父类的属性来解归档

---	

##### 动态交换两个方法的实现（特别是交换系统自带的方法）
		
		 如:我们利用运行时,可以在调用start方法的时候，实现调用到stop方法，但是，这有什么用呢？
		
		start {
		     开始
		}
		
		stop {
		     停止
		}
		
		
		* 试想，我们可以拦截系统的某些方法，来实现我们需要平时无法完成的事
		
		如：
		我们自己写一个alloc方法，把系统的alloc方法换了，在内部实现计数器+1，那么只要alloc创建对象的时就会调用到我们自己实现的alloc方法总，我们就可以知道我们内存中有多少个对象
		
		
		我们也可以拦截系统的[UIImage imageNamed：]方法，将系统方法给换了，那么我么就可以知道我们在整个项目中加载了多少图片，总共内存有多少


######runtime运用举例
* 描述，在ios6中属于拟物化时代，而ios7属于扁平化，那么我们经常遇到版本的适配问题，在遇到不同版本的时候我们需要展现给用户的图片样式不一样。我们是不是要在每个有图片的地方都加在意判断如果是ios7，换成扁平化图片呢？如果图片太多，不是疯了吗。那么这个时候runtime交换方法就派上了用场


		** 我们只需要在UIImage的分类中实现以下方法就可以轻松实现我们的需求 **
		
		+ (void)load {	//当系统加载到UIImage这个类时，我么做方法的交换
		
		// 获得需要交换的两个方法
	    Method mSys = class_getClassMethod([UIImage class], @selector(imageNamed:));
	    Method mMy = class_getClassMethod([UIImage class], @selector(px_imageName:));
	    
	    // 交换方法的实现
	    method_exchangeImplementations(mSys, mMy);
	
		}
		
	
		// 自定义一个方法，准备用来与系统方法交换
		+(UIImage *)px_imageName:(NSString *)imageName {
		
		    double version = [[UIDevice currentDevice].systemVersion doubleValue];
		    if (version >= 7.0) {
		        imageName = [imageName stringByAppendingString:@"_os7"];
		    }
		    
		    // 调回系统的方法
		    // 这里需要调用系统方法来赋值，我们就应该调用自己的方法交换到系统的方法
		    return [UIImage px_imageName:imageName];
		}



* 现在我们来分析下，交换方法是怎么实现的

		 系统会通过seletor的方法名 找到对应的方法名的 具体实现，
			方法名							方法的实现
		`@selector(imageNamed:)`  --->  `imageNamed:`
		`@selector(px_imageName:)` ---> `px_imageName:`
	
		
		那么在调用了`method_exchangeImplementations(mSys, mMy);` 以后他们的selector指向就发生了改变，这是seletcor通过方法名找的就是交换后的方法实现
			方法名							方法的实现
		`@selector(imageNamed:)`  --->  `px_imageName:`
		`@selector(px_imageName:)` ---> `imageNamed:`
	
	
	
####注意：
	需要注意的是：如果我们直接通过分类方法来实现`imageNamed:`方法是不行的，系统会报警告
	
	“Category is implementing a method which will also be implemented by its primary class” ---> 我在category中重写了原类的方法 而苹果的官方文档中明确表示  我们不应该在category中复写原类的方法，如果要重写 请使用继承
	
	原文是这样的： category allows you to add new methods to an existing class. If you want to reimplement a method that already exists in the class, you typically create a subclass instead of a category. 
	
	我们在这里并没有重写系统的原生的方法，我们只是使用自己的方法实现了要做的事，然后又调用回系统原生的方法，这样我们没有改变系统原生的内部实现，对系统本身并没有伤害
	


 



###3.  编译时最终会将OC的代码转换为 运行时代码 

* clang -rewrite-objc xxxx.m
	
		在官方文档中是这样描述的
			
		In Objective-C, messages aren’t bound to method implementations until runtime. The compiler converts a message expression.
		
			[receiver message]
			
		into a call on a messaging function, objc_msgSend. This function takes the receiver and the name of the method mentioned in the message—that is, the method selector—as its two principal parameters:
	
	 举例
		NSString *str = @"hello";
		[str length];
		
		最终转换成运行时表示出来：objc_msgSend（str,@selector(length)）;
	
* [[NSObjcet alloc] init

		最终转换为下面的运行时代码
		
		id objc = objc_msgSend(objc_getClass("NSObject"), sel_registerName("alloc"));		
		objc_msgSend(objc, sel_registerName("init"));
		
		用文字描述应该是给NSObjcet这个类发送了一个alloc消息，返回了一个这个类的对象，然后再给这个对象发送了个init消息，初始化这个对象



---


###4. 运行时的应用，分类增加属性

* 要求：我们给NSObject的category增加一个属性，是所有OC对象都能使用这个属性

* 我们都知道`@property`可以给我们生成属性的`get` 和 `set` 方法的声明和实现，并且生成带下划线的成员变量。
* 但是分类是不能增加属性的，`@property` 只能为其生成`get` 和 `set` 方法的声明，更无法生成带下划线的成员变量，一旦程序执行后会crash,如果非要使用，那么就得自己定义一个全局变量来，实现属性的`get` 和 `set` 方法的实现。

* runtime引入--全局变量程序整个运行过程中内存中`只有一份`，那么如果有`多个对象`，其中一个对象`修改`了这个全局变量，就会改变这个全局变量的值，`导致影响`到其他对象的使用。所以，使用全局变量来保存分类属性值也是存在问题的。为了保证`每个对象`都有`独立的内存空间`来存放这个值，我们就需要借助runtime的设置关联对象`objc_setAssociatedObject`来实现。
  	
* 如何理解`objc_setAssociatedObject`呢，也就是`将某个值 与 某个对象关联起来`或者`将某个值 存储到 某个对象中`
  
  
 
  ###### objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy)
  ######描述这句代码:将值 value 通过 key 与对象 objc 关联起来 (将 value 存储到 objc 中)
  
  
  
**  参数说明 **
  
  `<id object>` ：需要存值的对象 （哪个对象调用就表示哪个对象需要把值关联起来）
  
  `<const void *key>` ：根据这个key来存取值，这个key,与字典一样，一个key对应保存一个value,而void * 与id类型相似，表示这个key什么都可以用，但是推荐使用char,节省空间
  
  `<id value>` ：要存储的值 （要关联的值）
  
  `<objc_AssociationPolicy policy>` ：存储策略 （表示用什么方式来引用存储的值，如assign ，copy ， retain就，strong）
   
 
 
##### objc_getAssociatedObject(id object, const void *key)

######描述这句代码:通过 key 从关联对象 objct 中获取值




#####举例

* 给NSObject添加一个Catefory

		@interface NSObject (Name)
		
		@property (nonatomic, copy) NSString *name;


* 实现set 和 get 方法
 
		 - (void)setName:(NSString *)name {
		    
		    ///  设置关联对象
		    ///
		    ///  @param object#> 哪个对象需要存储值  一般是self
		    ///  @param key#>    根据这个key关联对象，(void *类型)建议使用char
		    ///  @param value#>  需要关联的值
		    ///  @param policy#> 存储策略
		    
		    objc_setAssociatedObject(self, &nameKey, name, OBJC_ASSOCIATION_COPY_NONATOMIC);
		    
		}
		
			
			- (NSString *)name {
		    
		    // 获取关联对象的值
		    return objc_getAssociatedObject(self, &nameKey);
		
		}
  	
  	
* viewDidLoad打印--每个对象都有自己的独立空间

		- (void)viewDidLoad {
		    [super viewDidLoad];
		 
		    NSString *str = [NSString string];
		    str.name = @"字符串";
		    
		    NSArray *array = [NSArray array];
		    array.name = @"数组";
		    
		    UITableView *tableView = [[UITableView alloc] init];
		    tableView.name = @"tableView";
		    
		    NSLog(@"%@--%@--%@",str.name,array.name,tableView.name);
		}
  	
  	
  	

###5.实现字典和模型的转换

* runtime实现简单字典转模型

* viewDidLoad做一个简陋的数据凑合下

		NSDictionary *dict = @{
		                         @"name" : @"andy",
		                         @"height" : @1.70,
		                         @"weight" : @50,
		                         @"age" : @20,
		                         @"money" : @10 //比模型多一个键值对
		                        };


* 创建模型类,属性与字典中的key相对应
* Person模型类

		@property (nonatomic,copy) NSString *name;
		@property (nonatomic,assign) double height;
		@property (nonatomic,assign) double weight;
		@property (nonatomic,assign) int age;
		




* @implementation NSObject (Extension)

* 自定义一个对象方法来实现转换

		- (void)setDict:(NSDictionary *)dict {
		
		    Class currentClass = self.class;

		    while (currentClass && currentClass != [NSObject class]) {
		        
		        unsigned int outCount = 0;
		        // 获取类的所有成员变量
		        Ivar *ivars = class_copyIvarList(currentClass, &outCount);
		        // 逐个获取
		        for (int i = 0; i < outCount; i++) {
		            Ivar ivar = ivars[i];
		            
		            // 获得类的所有成员变量
		            NSString *key = @(ivar_getName(ivar));
		            
		            key = [key substringFromIndex:1];
		            
		            id value = dict[key];
		            
		            [self setValue:value forKeyPath:key];
		            
		        }
		        // 释放
		        free(ivars);
		        // 重新赋值当前的类
		        currentClass = [currentClass superclass];
		    }
		}


* 再提供一个类方法,使用更方便

		+ (instancetype)objectWithDict:(NSDictionary *)dict {
		    
		    // 创建模型对象
		    NSObject *objc = [[self alloc] init];
		    
		    [objc setDict:dict];
		    
		    return objc;
		}


* viewDidLoad 打印测试

	    Person *per = [Person objectWithDict:dict];
	
	    NSLog(@"%@--%lf--%lf--%zd",per.name,per.height,per.weight,per.age);
	    

**小结**

上面的小例子中,我们的字典中键值对比模型中属性多一组键值对

如果,使用KVC的情况下系统会直接crash,但是我们用runtime实现的方法执行过程是与KVC相反的,我们都知道KVC是从字典下手,从字典中把每一个键对应的值取出来,给模型属性赋值,而我们用runtime实现的方法执行过程是先遍历模型属性,模型中有的属性我们采取字典中找,如果模型中没有,我们就不去找,那么就不会出现不匹配的情况

  	
  	
####字典嵌套字典

* 在原来简陋的字典基础上添加了Dog模型,和Bone模型,
* Person 中有 Dog , Dog 中有 Bone

	    NSDictionary *dict = @{
	                           @"name" : @"andy",
	                           @"height" : @1.70,
	                           @"weight" : @50,
	                           @"age" : @20,
	                           @"dog" : @{
	                               @"name" : @"wangcai",
	                               @"leg" : @4,
	                               @"bone" : @{
	                                   @"name" : @"大骨头",
	                                   @"weight" : @200
	                               },
	                           },
	                           @"money" : @10 // 酱油属性,测试是否crash
	                           };


  	
* 实现

		- (void)setDict:(NSDictionary *)dict {
		
		    Class currentClass = self.class;
		
		    while (currentClass && currentClass != [NSObject class]) {
		        
		        unsigned int outCount = 0;
		        // 获取类的所有成员变量
		        Ivar *ivars = class_copyIvarList(currentClass, &outCount);
		        // 逐个获取
		        for (int i = 0; i < outCount; i++) {
		            Ivar ivar = ivars[i];
		            
		            // 获得类的所有属性
		            NSString *key = @(ivar_getName(ivar));
		            key = [key substringFromIndex:1];
		            // 取出字典
		            id value = dict[key];
		            
		            // 获取当前属性的类型
		            NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
		
		            // 查询类型中是否有"@"
		            NSRange range = [type rangeOfString:@"@"];
		
		            if (range.location != NSNotFound) {  // 能找到"@"
		                type = [type substringWithRange:NSMakeRange(2, type.length - 3)];
		                if (![type hasPrefix:@"NS"]) {
		                    Class class = NSClassFromString(type);
		                    value = [class objectWithDict:value];
		                }
		            }
		            
		            [self setValue:value forKeyPath:key];
		        }
		        // 释放
		        free(ivars);
		        // 重新赋值当前的类
		        currentClass = [currentClass superclass];
		    }
		}
  	
  	
**小结**

	1.在模型嵌套模型的情况中,我们首先要分析数据,谁包含了谁,如:Person中包含了Dog,Dog类中又是一个字典,那么我首先由内向外,一层层转换,先将Dog中的字典转换为模型,在来搞外层字典.
	
	2.这里用到了`ivar_getTypeEncoding(ivar)`来获取属性的类型,是为了区别于其他的属性,用查询字符串和截取字符串的方法一步步接近我们要的目标,最终获得我们想要的类
	
	3.拿到内层的类后,取出这个类对应的字典value,做一次转模型,最后将得到的模型设置给对应的属性 	
  	
  	

####字典嵌套数组

* 字典中再嵌套一层数组books

* Person中在再添加一个数组的数组 `@property (nonatomic,strong) NSArray *books;`

		 NSDictionary *dict = @{
		                           @"name" : @"andy",
		                           @"height" : @1.70,
		                           @"weight" : @50,
		                           @"age" : @20,
		                           @"dog" : @{
		                               @"name" : @"wangcai",
		                               @"leg" : @4,
		                           },
		                           @"books" : @[
		                                   @{
		                                       @"name" : @"goodBook",
		                                       @"color" : @"yellow",
		                                       @"price" : @10
		                                       },
		                                   @{
		                                       @"name" : @"badBook",
		                                       @"color" : @"red",
		                                       @"price" : @20
		                                       }
		                                   ],
		                           @"money" : @10 // 酱油属性,测试是否crash
		                           };




* 实现 @implementation NSObject (Extension)

* 变化主要是在对象方法中,判断是否是NSArray的类型


		- (void)setDict:(NSDictionary *)dict {
		
		    Class currentClass = self.class;
		
		    while (currentClass && currentClass != [NSObject class]) {
		        
		        unsigned int outCount = 0;
		        // 获取类的所有成员变量
		        Ivar *ivars = class_copyIvarList(currentClass, &outCount);
		        // 逐个获取
		        for (int i = 0; i < outCount; i++) {
		            Ivar ivar = ivars[i];
		            
		            // 获得类的所有属性
		            NSString *key = @(ivar_getName(ivar));
		            key = [key substringFromIndex:1];
		            // 取出字典
		            id value = dict[key];
		            // 如果字典中没有对应属性的值
		            if (value == nil) continue;
		            
		            // 获取当前属性的类型
		            NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
		           
		
		            // 查询类型中是否有"@"
		            NSRange range = [type rangeOfString:@"@"];
		            
		            if (range.location != NSNotFound) {  // 能找到"@"
		                type = [type substringWithRange:NSMakeRange(2, type.length - 3)];
		
		                if (![type hasPrefix:@"NS"]) {
		                   Class class = NSClassFromString(type);
		                    value = [class objectWithDict:value];
		
		                } else {
		                
		                //  这里如果判断是带NS的前缀才会进入
		                
		                *******变化的地方********
		                    
		                    Class class = NSClassFromString(type);
		                    if ([class isSubclassOfClass:[NSArray class]]) {
		                        
		                        // 获得数组
		                        NSArray *array = (NSArray *)value;
		                        
		                        NSMutableArray *arrayM = [NSMutableArray array];
		                        
		                        // 数组里面装的都是Book类型的字典
		                        for (NSDictionary *dict in array) {
		                         
		                            // 将字典转模型
		                            Book *book = [Book objectWithDict:dict];
		                            
		                            [arrayM addObject:book];
		                        }
		                        
		                        value = arrayM;
		                    }
		                    
		              ***********变化的地方************
		              
		                }
		            }
		
		            [self setValue:value forKeyPath:key];
		        }
		        // 释放
		        free(ivars);
		        // 重新赋值当前的类
		        currentClass = [currentClass superclass];
		    }
		}
		

* 再提供一个类方法,使用更方便
		
		// 提供一个类方法,方便调用
		+ (instancetype)objectWithDict:(NSDictionary *)dict {
		    
		    // 创建模型对象
		    NSObject *objc = [[self alloc] init];
		    
		    [objc setDict:dict];
		    
		    return objc;
		}


* 控制测试

		 Person *per = [Person objectWithDict:dict];
		
		    for (Book *book in per.books) {
		        
		        NSLog(@"%@--%@--%zd",book.name,book.color,book.price);
		    }
		    


**小结**

1.在字典嵌套数组的情况中,我们需要首先创建一个对应数组的模型类出来

2.判断遍历的到key对应的type是否是NSArray类型

3.获得key对应的value

4.将value转换为模型赋值给对应的属性

  	
---

整理这篇文章,主要是为了给自己整理下思路,也是作为一个笔记,以备以后忘了,可以常来看看,希望也能帮助到刚接触运行时基本方法的朋友,最后感谢杰哥,借鉴了部分滕先洪的runtime,谢谢
