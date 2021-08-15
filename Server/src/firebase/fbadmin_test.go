package fbadmin_test

import (
	"container/list"
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

func TestGetUIDFromLocation(t *testing.T) {
	// Configure vars
	App := fbadmin.FirebaseApp{}
	App.InitFirebase()

	testingUID := "hmHIk2gjMCScZimPXzziVDzf2Pz1"
	testingLocation := "TestGetLocation"

	// Add user to location first
	status := -1
	list := list.List{}
	App.GetUIDFromLocation(&status, testingLocation, &list)
	if status == -1 {
		t.Error("GetUIDFromLocation() should be called & finish executing")
	} else if status == 0 {
		t.Error("GetUIDFromLocation() should save the UID to the location sucessfully")
	} else {
		// Iterate the list
		// if the testinf UID is found in the list, success
		success := 0
		for e := list.Front(); e != nil; e = e.Next() {
			uid := e.Value.(string)
			if uid == testingUID {
				success = 1
				break
			}
		}
		if success == 0 {
			t.Error("GetUIDFromLocation() the UID couldn't be get from the location")
		}
	}

}

func TestSaveUIDToLocation(t *testing.T) {

	// Configure vars
	App := fbadmin.FirebaseApp{}
	App.InitFirebase()

	testingUID := "hmHIk2gjMCScZimPXzziVDzf2Pz1"
	testingLocation := "TestLocation"

	// Add user to location first
	status := -1
	App.SaveUIDToLocation(&status, testingUID, testingLocation)

	if status == -1 {
		t.Error("SaveUIDToLocation() should be called & finish executing")
	} else if status == 0 {
		t.Error("SaveUIDToLocation() should save the UID to the location sucessfully")
	} else {
		status := -1
		list := list.List{}
		App.GetUIDFromLocation(&status, testingLocation, &list)
		// Iterate the list
		// if the testinf UID is found in the list, success
		success := 0
		for e := list.Front(); e != nil; e = e.Next() {
			uid := e.Value.(string)
			if uid == testingUID {
				success = 1
				break
			}
		}
		if success == 0 {
			t.Error("SaveUIDToLocation() the UID couldn't be found in the location")
		}
		// SUCCESS, DO NOTHING, REMOVE TEST PROCESSES NEXT AND HANDLES CLEANUP TOO
	}

}

func TestRemoveUIDFromLocation(t *testing.T) {

	// THIS WILL PASS ONLY IF TestSaveUIDToLocation() IS CALLED BEFORE THIS FUNCTION
	// OR IF SaveUIDToLocation() is called here

	// Configure vars
	App := fbadmin.FirebaseApp{}
	App.InitFirebase()

	testingUID := "hmHIk2gjMCScZimPXzziVDzf2Pz1"
	testingLocation := "TestLocation"

	// Add user to location first
	_, fail := App.RemoveUIDFromLocation(testingUID, testingLocation)
	if fail != "" {
		t.Errorf("RemoveUIDFromLocation() failed; %s", fail)
	} else {
		// SUCCESS, DO NOTHING
	}

}
