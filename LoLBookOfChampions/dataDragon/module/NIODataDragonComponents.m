//
// NIODataDragonComponents / LoLBookOfChampions
//
// Created by Jeff Roberts on 1/23/15.
// Copyright (c) 2015 Riot Games. All rights reserved.
//

#import "NIODataDragonComponents.h"
#import "NIOLoLApiRequestOperationManager.h"
#import "NIOGetRealmTask.h"
#import "NIODataDragonSyncService.h"
#import "NIOContentProvider.h"
#import "NIODataDragonContentProvider.h"
#import "NIOCoreComponents.h"
#import "NIODataDragonContract.h"
#import "NIODataDragonSqliteOpenHelper.h"
#import "NIOQueryRealmsTask.h"
#import "NIODeleteRealmTask.h"
#import "NIOClearLocalDataDragonDataTask.h"
#import "NIOInsertRealmTask.h"
#import "NIOInsertDataDragonRealmTask.h"
#import "NIOGetChampionStaticDataTask.h"
#import "NIODeleteChampionTask.h"
#import "NIODeleteChampionSkinTask.h"
#import "NIOInsertChampionTask.h"
#import "NIOInsertChampionSkinTask.h"
#import "NIODataDragonCDNRequestOperationManager.h"
#import "NIOInsertDataDragonChampionDataTask.h"
#import "NIOCacheChampionImagesTask.h"
#import "NIOQueryChampionsTask.h"
#import "NIOQueryChampionSkinsTask.h"
#import "NIOSQLStatementBuilder.h"
#import "NIODefaultSQLStatementBuilder.h"
#import <Typhoon/Typhoon.h>


@implementation NIODataDragonComponents

-(id)config {
	return [TyphoonDefinition configDefinitionWithName:@"DataDragonConfiguration.plist"];
}

-(NIOCacheChampionImagesTask *)cacheChampionImagesTask {
	return [TyphoonDefinition withClass:[NIOCacheChampionImagesTask class] configuration:^(TyphoonDefinition *definition) {
		[definition useInitializer:@selector(initWithRequestOperationManager:) parameters:^(TyphoonMethod *initializer) {
			[initializer injectParameterWith:self.dataDragonCDNRequestOperationManager];
		}];

		definition.scope = TyphoonScopePrototype;
	}];
}


-(NIOClearLocalDataDragonDataTask *)clearLocalDataDragonDataTask {
	return [TyphoonDefinition withClass:[NIOClearLocalDataDragonDataTask class] configuration:^(TyphoonDefinition *definition) {
		[definition useInitializer:@selector(initWithContentResolver:withSharedURLCache:withExecutionExecutor:withCompletionExecutor:) parameters:^(TyphoonMethod *initializer) {
			[initializer injectParameterWith:self.coreComponents.contentResolver];
			[initializer injectParameterWith:self.coreComponents.sharedURLCache];
            [initializer injectParameterWith:self.coreComponents.databaseExecutionExecutor];
            [initializer injectParameterWith:self.coreComponents.databaseCompletionExecutor];
		}];

		definition.scope = TyphoonScopePrototype;
	}];
}

-(NIODataDragonCDNRequestOperationManager *)dataDragonCDNRequestOperationManager {
	return [TyphoonDefinition withClass:[NIODataDragonCDNRequestOperationManager class] configuration:^(TyphoonDefinition *definition) {
		[definition useInitializer:@selector(initWithSessionConfiguration:completionQueue:) parameters:^(TyphoonMethod *initializer) {
			[initializer injectParameterWith:[NSURLSessionConfiguration defaultSessionConfiguration]];
			[initializer injectParameterWith:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
		}];

		definition.scope = TyphoonScopeWeakSingleton;
	}];
}

-(NIODataDragonContentProvider *)dataDragonContentProvider {
	return [TyphoonDefinition withClass:[NIODataDragonContentProvider class] configuration:^(TyphoonDefinition *definition) {
		[definition useInitializer:@selector(initWithTaskFactory:withSqliteOpenHelper:) parameters:^(TyphoonMethod *initializer) {
			[initializer injectParameterWith:self.coreComponents.taskFactory];
			[initializer injectParameterWith:self.dataDragonSqliteOpenHelper];
		}];

		definition.scope = TyphoonScopeWeakSingleton;
	}];
}

-(FMDatabase *)dataDragonSqliteDatabase {
	return [TyphoonDefinition withFactory:self.dataDragonSqliteOpenHelper selector:@selector(database)];
}

-(NIODataDragonSqliteOpenHelper *)dataDragonSqliteOpenHelper {
	return [TyphoonDefinition withClass:[NIODataDragonSqliteOpenHelper class] configuration:^(TyphoonDefinition *definition) {
		[definition useInitializer:@selector(initWithName:withVersion:) parameters:^(TyphoonMethod *initializer) {
			[initializer injectParameterWith:TyphoonConfig(@"database.name")];
			[initializer injectParameterWith:TyphoonConfig(@"database.version")];
		}];

		definition.scope = TyphoonScopeLazySingleton;
	}];
}


-(NIODataDragonSyncService *)dataDragonSyncService {
	return [TyphoonDefinition withClass:[NIODataDragonSyncService class] configuration:^(TyphoonDefinition *definition) {
		[definition useInitializer:@selector(initWithContentResolver:withTaskFactory:) parameters:^(TyphoonMethod *initializer) {
			[initializer injectParameterWith:self.coreComponents.contentResolver];
			[initializer injectParameterWith:self.coreComponents.taskFactory];
		}];

		definition.scope = TyphoonScopeWeakSingleton;
	}];
}

-(NIODeleteChampionTask *)deleteChampionTask {
	return [TyphoonDefinition withClass:[NIODeleteChampionTask class] configuration:^(TyphoonDefinition *definition) {
		[definition useInitializer:@selector(initWithDatabase:withSQLStatementBuilder:) parameters:^(TyphoonMethod *initializer) {
			[initializer injectParameterWith:self.dataDragonSqliteDatabase];
			[initializer injectParameterWith:self.sqlStatementBuilder];
		}];

		definition.scope = TyphoonScopePrototype;
	}];
}

-(NIODeleteChampionSkinTask *)deleteChampionSkinTask {
	return [TyphoonDefinition withClass:[NIODeleteChampionSkinTask class] configuration:^(TyphoonDefinition *definition) {
		[definition useInitializer:@selector(initWithDatabase:withSQLStatementBuilder:) parameters:^(TyphoonMethod *initializer) {
			[initializer injectParameterWith:self.dataDragonSqliteDatabase];
			[initializer injectParameterWith:self.sqlStatementBuilder];
		}];

		definition.scope = TyphoonScopePrototype;
	}];
}

-(NIODeleteRealmTask *)deleteRealmsTask {
	return [TyphoonDefinition withClass:[NIODeleteRealmTask class] configuration:^(TyphoonDefinition *definition) {
		[definition useInitializer:@selector(initWithDatabase:withSQLStatementBuilder:) parameters:^(TyphoonMethod *initializer) {
			[initializer injectParameterWith:self.dataDragonSqliteDatabase];
			[initializer injectParameterWith:self.sqlStatementBuilder];
		}];

		definition.scope = TyphoonScopePrototype;
	}];
}

-(NIOGetChampionStaticDataTask *)getChampionStaticDataTask {
	return [TyphoonDefinition withClass:[NIOGetChampionStaticDataTask class] configuration:^(TyphoonDefinition *definition) {
		[definition useInitializer:@selector(initWithHTTPRequestOperationManager:) parameters:^(TyphoonMethod *initializer) {
			[initializer injectParameterWith:self.lolStaticDataApiRequestOperationManager];
		}];

		definition.scope = TyphoonScopePrototype;
	}];
}

-(NIOGetRealmTask *)getRealmTask {
	return [TyphoonDefinition withClass:[NIOGetRealmTask class] configuration:^(TyphoonDefinition *definition) {
		[definition useInitializer:@selector(initWithHTTPRequestOperationManager:) parameters:^(TyphoonMethod *initializer) {
			[initializer injectParameterWith:self.lolStaticDataApiRequestOperationManager];
		}];

		definition.scope = TyphoonScopePrototype;
	}];
}

-(NIOInsertChampionTask *)insertChampionTask {
	return [TyphoonDefinition withClass:[NIOInsertChampionTask class] configuration:^(TyphoonDefinition *definition) {
		[definition useInitializer:@selector(initWithDatabase:withSQLStatementBuilder:) parameters:^(TyphoonMethod *initializer) {
			[initializer injectParameterWith:self.dataDragonSqliteDatabase];
			[initializer injectParameterWith:self.sqlStatementBuilder];
		}];

		definition.scope = TyphoonScopePrototype;
	}];
}

-(NIOInsertChampionSkinTask *)insertChampionSkinTask {
	return [TyphoonDefinition withClass:[NIOInsertChampionSkinTask class] configuration:^(TyphoonDefinition *definition) {
		[definition useInitializer:@selector(initWithDatabase:withSQLStatementBuilder:) parameters:^(TyphoonMethod *initializer) {
			[initializer injectParameterWith:self.dataDragonSqliteDatabase];
			[initializer injectParameterWith:self.sqlStatementBuilder];
		}];

		definition.scope = TyphoonScopePrototype;
	}];
}

-(NIOInsertDataDragonChampionDataTask *)insertDataDragonChampionDataTask {
	return [TyphoonDefinition withClass:[NIOInsertDataDragonChampionDataTask class] configuration:^(TyphoonDefinition *definition) {
		[definition useInitializer:@selector(initWithContentResolver:withExecutionExecutor:withCompletionExecutor:) parameters:^(TyphoonMethod *initializer) {
			[initializer injectParameterWith:self.coreComponents.contentResolver];
            [initializer injectParameterWith:self.coreComponents.databaseExecutionExecutor];
            [initializer injectParameterWith:self.coreComponents.databaseCompletionExecutor];
		}];

		definition.scope = TyphoonScopePrototype;
	}];
}

-(NIOInsertDataDragonRealmTask *)insertDataDragonRealmTask {
	return [TyphoonDefinition withClass:[NIOInsertDataDragonRealmTask class] configuration:^(TyphoonDefinition *definition) {
		[definition useInitializer:@selector(initWithContentResolver:withExecutionExecutor:withCompletionExecutor:) parameters:^(TyphoonMethod *initializer) {
			[initializer injectParameterWith:self.coreComponents.contentResolver];
            [initializer injectParameterWith:self.coreComponents.databaseExecutionExecutor];
            [initializer injectParameterWith:self.coreComponents.databaseCompletionExecutor];
		}];

		definition.scope = TyphoonScopePrototype;
	}];
}

-(NIOInsertRealmTask *)insertRealmTask {
	return [TyphoonDefinition withClass:[NIOInsertRealmTask class] configuration:^(TyphoonDefinition *definition) {
		[definition useInitializer:@selector(initWithDatabase:withSQLStatementBuilder:) parameters:^(TyphoonMethod *initializer) {
			[initializer injectParameterWith:self.dataDragonSqliteDatabase];
			[initializer injectParameterWith:self.sqlStatementBuilder];
		}];

		definition.scope = TyphoonScopePrototype;
	}];
}

-(NIOLoLApiRequestOperationManager *)lolStaticDataApiRequestOperationManager {
	return [TyphoonDefinition withClass:[NIOLoLApiRequestOperationManager class] configuration:^(TyphoonDefinition *definition) {
		[definition useInitializer:@selector(initWithBaseURL:sessionConfiguration:completionQueue:apiKey:region:apiVersion:) parameters:^(TyphoonMethod *initializer) {
			[initializer injectParameterWith:TyphoonConfig(@"global.endpoint")];
			[initializer injectParameterWith:[NSURLSessionConfiguration defaultSessionConfiguration]];
			[initializer injectParameterWith:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
			[initializer injectParameterWith:TyphoonConfig(@"api.key")];
			[initializer injectParameterWith:TyphoonConfig(@"lol.region")];
			[initializer injectParameterWith:TyphoonConfig(@"static.data.api.version")];
		}];

		definition.scope = TyphoonScopeWeakSingleton;
	}];
}

-(NIOQueryChampionsTask *)queryChampionsTask {
	return [TyphoonDefinition withClass:[NIOQueryChampionsTask class] configuration:^(TyphoonDefinition *definition) {
		[definition useInitializer:@selector(initWithDatabase:withSQLStatementBuilder:) parameters:^(TyphoonMethod *initializer) {
			[initializer injectParameterWith:self.dataDragonSqliteDatabase];
			[initializer injectParameterWith:self.sqlStatementBuilder];
		}];

		definition.scope = TyphoonScopePrototype;
	}];
}

-(NIOQueryChampionSkinsTask *)queryChampionSkinsTask {
	return [TyphoonDefinition withClass:[NIOQueryChampionSkinsTask class] configuration:^(TyphoonDefinition *definition) {
		[definition useInitializer:@selector(initWithDatabase:withSQLStatementBuilder:) parameters:^(TyphoonMethod *initializer) {
			[initializer injectParameterWith:self.dataDragonSqliteDatabase];
			[initializer injectParameterWith:self.sqlStatementBuilder];
		}];

		definition.scope = TyphoonScopePrototype;
	}];
}

-(NIOQueryRealmsTask *)queryRealmsTask {
	return [TyphoonDefinition withClass:[NIOQueryRealmsTask class] configuration:^(TyphoonDefinition *definition) {
		[definition useInitializer:@selector(initWithDatabase:withSQLStatementBuilder:) parameters:^(TyphoonMethod *initializer) {
			[initializer injectParameterWith:self.dataDragonSqliteDatabase];
			[initializer injectParameterWith:self.sqlStatementBuilder];
		}];

		definition.scope = TyphoonScopePrototype;
	}];
}

-(id<NIOSQLStatementBuilder>)sqlStatementBuilder {
	return [TyphoonDefinition withClass:[NIODefaultSQLStatementBuilder class] configuration:^(TyphoonDefinition *definition) {
		[definition useInitializer:@selector(init) parameters:^(TyphoonMethod *initializer) {
		}];

		definition.scope = TyphoonScopePrototype;
	}];
}


@end