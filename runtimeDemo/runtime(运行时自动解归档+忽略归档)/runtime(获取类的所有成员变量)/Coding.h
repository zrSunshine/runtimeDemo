
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