# JXChannelSegment#

![logo](http://www.imjackxu.com/images/jxsegment.gif)

## How to use ?
	
	//init Segment
    segment = [[JXSegment alloc] initWithFrame:CGRectMake(0, 60, SCREEN_WIDTH, 40)];
    [segment updateChannels:@[@"首页",@"文章",@"好东西",@"早点与宵夜",@"电子小物",@"苹果",@"收纳集合",@"JBL",@"装b利器",@"测试机啦啦",@"乱七八糟的"]];
    segment.delegate = self;
    [self.view addSubview:segment];
    
    //init Page
    pageView =[[JXPageView alloc] initWithFrame:CGRectMake(0, 100, SCREEN_WIDTH, self.view.bounds.size.height - 100)];
    pageView.datasource = self;
    pageView.delegate = self;
    [pageView reloadData];
    [pageView changeToItemAtIndex:0];
    [self.view addSubview:pageView];
   
<admin@imjackxu.com>