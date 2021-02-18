//
//  Builder.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/07/20.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import JobOrder_Domain
import JobOrder_API
import JobOrder_Data

struct Builder {
    var robotDataRepository: JobOrder_Data.RobotDataStore {
        JobOrder_Data.RobotDataStore(ud: JobOrder_Data.UserDefaultsDataStore(),
                                     realm: JobOrder_Data.RealmDataStore())
    }
    var jobDataRepository: JobOrder_Data.JobDataStore {
        JobOrder_Data.JobDataStore(ud: JobOrder_Data.UserDefaultsDataStore(),
                                   realm: JobOrder_Data.RealmDataStore())
    }
    var actionLibraryDataRepository: JobOrder_Data.ActionLibraryDataStore {
        JobOrder_Data.ActionLibraryDataStore(ud: JobOrder_Data.UserDefaultsDataStore(),
                                             realm: JobOrder_Data.RealmDataStore())
    }
    var aiLibraryDataRepository: JobOrder_Data.AILibraryDataStore {
        JobOrder_Data.AILibraryDataStore(ud: JobOrder_Data.UserDefaultsDataStore(),
                                         realm: JobOrder_Data.RealmDataStore())
    }
    var settingsRepository: JobOrder_Data.SettingsDataStore {
        JobOrder_Data.SettingsDataStore(ud: JobOrder_Data.UserDefaultsDataStore(),
                                        keychain: JobOrder_Data.KeychainDataStore())
    }
    var publicRepository: JobOrder_API.PublicAPIDataStore {
        JobOrder_API.PublicAPIDataStore(api: JobOrder_API.APIRequest())
    }
    var robotRepository: JobOrder_API.RobotAPIDataStore {
        JobOrder_API.RobotAPIDataStore(api: JobOrder_API.APIRequest())
    }
    var jobRepository: JobOrder_API.JobAPIDataStore {
        JobOrder_API.JobAPIDataStore(api: JobOrder_API.APIRequest())
    }
    var taskRepository: JobOrder_API.TaskAPIDataStore {
        JobOrder_API.TaskAPIDataStore(api: JobOrder_API.APIRequest())
    }
    var actionLibraryRepository: JobOrder_API.ActionLibraryAPIDataStore {
        JobOrder_API.ActionLibraryAPIDataStore(api: JobOrder_API.APIRequest())
    }
    var aiLibraryRepository: JobOrder_API.AILibraryAPIDataStore {
        JobOrder_API.AILibraryAPIDataStore(api: JobOrder_API.APIRequest())
    }
    var authUseCase: JobOrder_Domain.AuthenticationUseCase {
        JobOrder_Domain.AuthenticationUseCase(authRepository: JobOrder_API.AWSAuthenticationDataStore(),
                                              mqttRepository: JobOrder_API.AWSIoTDataStore(),
                                              videoRepository: JobOrder_API.AWSKVSDataStore(),
                                              analyticsServiceRepository: JobOrder_API.AWSAnalyticsDataStore(),
                                              publicAPIRepository: publicRepository,
                                              settingsRepository: settingsRepository,
                                              userDefaultsRepository: JobOrder_Data.UserDefaultsDataStore(),
                                              keychainRepository: JobOrder_Data.KeychainDataStore(),
                                              robotDataRepository: robotDataRepository,
                                              jobDataRepository: jobDataRepository,
                                              actionLibraryDataRepository: actionLibraryDataRepository,
                                              aiLibraryDataRepository: aiLibraryDataRepository)
    }
    var mqttUseCase: JobOrder_Domain.MQTTUseCase {
        JobOrder_Domain.MQTTUseCase(authRepository: JobOrder_API.AWSAuthenticationDataStore(),
                                    mqttRepository: JobOrder_API.AWSIoTDataStore(),
                                    storageRepository: JobOrder_API.AWSS3DataStore(),
                                    keychainRepository: JobOrder_Data.KeychainDataStore(),
                                    robotDataRepository: robotDataRepository)
    }
    var settingsUseCase: JobOrder_Domain.SettingsUseCase {
        JobOrder_Domain.SettingsUseCase(settingsRepository: settingsRepository)
    }
    var dataUseCase: JobOrder_Domain.DataManageUseCase {
        JobOrder_Domain.DataManageUseCase(authRepository: JobOrder_API.AWSAuthenticationDataStore(),
                                          mqttRepository: JobOrder_API.AWSIoTDataStore(),
                                          robotAPIRepository: robotRepository,
                                          jobAPIRepository: jobRepository,
                                          actionLibraryAPIRepository: actionLibraryRepository,
                                          aILibraryAPIRepository: aiLibraryRepository,
                                          taskAPIRepository: taskRepository,
                                          userDefaultsRepository: JobOrder_Data.UserDefaultsDataStore(),
                                          robotDataRepository: robotDataRepository,
                                          jobDataRepository: jobDataRepository,
                                          actionLibraryDataRepository: actionLibraryDataRepository,
                                          aiLibraryDataRepository: aiLibraryDataRepository
        )
    }
    var analyticsUseCase: JobOrder_Domain.AnalyticsUseCase {
        JobOrder_Domain.AnalyticsUseCase(analyticsServiceRepository: JobOrder_API.AWSAnalyticsDataStore())
    }
    var videoStreamingUseCase: JobOrder_Domain.VideoStreamingUseCase {
        JobOrder_Domain.VideoStreamingUseCase(videoRepository: JobOrder_API.AWSKVSDataStore())
    }
}
