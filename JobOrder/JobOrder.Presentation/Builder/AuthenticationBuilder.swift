//
//  AuthenticationBuilder.swift
//  JobOrder
//
//  Created by Yu Suzuki on 2020/03/17.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

struct AuthenticationBuilder {

    struct PasswordAuthentication {
        func build(vc: PasswordAuthenticationViewControllerProtocol) -> PasswordAuthenticationPresenter {
            return PasswordAuthenticationPresenter(authUseCase: Builder().authUseCase,
                                                   settingsUseCase: Builder().settingsUseCase,
                                                   vc: vc)
        }
    }

    struct MailVerificationEntry {
        func build(vc: MailVerificationEntryViewControllerProtocol) -> MailVerificationEntryPresenter {
            return MailVerificationEntryPresenter(useCase: Builder().authUseCase,
                                                  vc: vc)
        }
    }

    struct MailVerificationConfirm {
        func build(vc: MailVerificationConfirmViewController, viewData: AuthenticationViewData) -> MailVerificationConfirmPresenter {
            return MailVerificationConfirmPresenter(useCase: Builder().authUseCase,
                                                    vc: vc,
                                                    viewData: viewData)
        }
    }

    struct NewPasswordRequired {
        func build(vc: NewPasswordRequiredViewController) -> NewPasswordRequiredPresenter {
            return NewPasswordRequiredPresenter(useCase: Builder().authUseCase,
                                                vc: vc)
        }
    }

    struct ConnectionSettings {
        func build(vc: ConnectionSettingsViewController) -> ConnectionSettingsPresenter {
            return ConnectionSettingsPresenter(useCase: Builder().settingsUseCase,
                                               vc: vc)
        }
    }
}
