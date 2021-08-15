package fbadmin_test

import (
	"testing"

	fbadmin "bismateServer/firebase"
)

func TestGetUserProfile(t *testing.T) {

	// Configure vars
	App := fbadmin.FirebaseApp{}
	App.InitFirebase()
	testingUID := "hmHIk2gjMCScZimPXzziVDzf2Pz1"

	status := -1
	App.GetUserProfile(&status, testingUID)

	switch status {
	case -1:
		t.Error("GetUserProfile() should be called & finish executing")
	case 0:
		t.Error("GetUserProfile() should retrieve the user profile successfully")
	case 1:
		// SUCCESS, DO NOTHING
	default:
		t.Error("GetUserProfile() status is unrecognised")
	}

}

func TestChangeDisplayName(t *testing.T) {

	// Configure vars
	App := fbadmin.FirebaseApp{}
	App.InitFirebase()

	testingUID := "hmHIk2gjMCScZimPXzziVDzf2Pz1"
	testingDisplayName := "TestDisplayName1"

	status := -1
	App.ChangeDisplayName(testingDisplayName, &status, testingUID)

	switch status {
	case -1:
		t.Error("ChangeDisplayName() should be called & finish executing")
	case 0:
		t.Error("ChangeDisplayName() should change the user display name successfully")
	case 1:
		// SUCCESS, CHECK THAT THE DISPLAY NAME HAS CHANGED INDEED
		statusInternal := -1
		user := App.GetUserProfile(&statusInternal, testingUID)
		if user.DisplayName == testingDisplayName {
			// SUCCESS, CLEANUP
			// App.ChangeDisplayName("", &statusInternal, testingUID)
		} else {
			t.Errorf("Test user display name should be: %s; got %s", testingDisplayName, user.DisplayName)
		}
	default:
		t.Error("GetUserProfile() status is unrecognised")
	}

}
