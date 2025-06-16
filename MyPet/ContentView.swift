import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        TabView {
            PetAlbumView()
                .tabItem {
                    Image(systemName: "photo.on.rectangle")
                    Text("앨범")
                }
            
            HospitalMapView()
                .tabItem {
                    Image(systemName: "cross.case")
                    Text("병원찾기")
                }
            
            ScheduleView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("일정")
                }
        }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("로그아웃") {
                            viewModel.signOut()
                        }
            }
        }
    }
}

