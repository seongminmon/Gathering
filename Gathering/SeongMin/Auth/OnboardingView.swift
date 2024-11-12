//
//  OnboardingView.swift
//  Gathering
//
//  Created by 김성민 on 11/12/24.
//

import SwiftUI

import ComposableArchitecture

struct OnboardingView: View {
    
    @Perception.Bindable var store: StoreOf<OnboardingFeature>
    
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 40) {
                Text("Gathering에서 모임을 만들고 참여해보세요")
                    .font(.system(size: 30, weight: .heavy))
                    .multilineTextAlignment(.center)
                
                Image(.splash)
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                
                Spacer()
                
                Button {
                    print("시작하기 버튼 탭")
                    store.send(.startButtonTap)
                } label: {
                    StartActiveButton()
                }
            }
            .padding(20)
            .sheet(isPresented: $store.isShowPopUpView) {
                LoginPopUpView()
                    .presentationDetents([.height(290)])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}
