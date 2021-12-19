import java.util.Collections;

PFont font;
final int FONT_SIZE = 20;
int maxDisplayTrack;

ArrayList<String> trackNames = new ArrayList<String>();
HashMap<String, String> trackPaths = new HashMap<String, String>();
final String[] EXTENSIONS = {".mp3", ".wav"};

int trackNum = 0;
int selectPosition = 0;

int loadFiles(File selection) {
  if (selection == null) {
    println("Folder selection was canceled.");
    return 1;
  } else {
    File[] files = selection.listFiles();
    for (int i = 0; i < files.length; i++) {
      for (String extension : EXTENSIONS) {
        if (files[i].getPath().endsWith(extension)) {
          if (!trackPaths.containsKey(files[i].getName().replace(extension, ""))) {
            trackNames.add(files[i].getName().replace(extension, ""));
            trackPaths.put(trackNames.get(trackNames.size() - 1), files[i].getAbsolutePath());
          }
        }
      }
    }
    if (trackNames.size() == 0) {
      println("Could not find audio file.");
      return 2;
    }
    ascendingSort();
    return 0;
  }
}

void initializeUISettings() {
  font = createFont("Menlo-Regular", FONT_SIZE);
  textFont(font, FONT_SIZE);
  maxDisplayTrack = floor(height / (FONT_SIZE * 1.2));
}

void selectTrack() {
  camera(width / 2.0, height / 2.0, (height / 2.0) / tan(PI / 6), width / 2.0, height / 2.0, 0.0, 0.0, 1.0, 0.0);
  for (int i = 0; i < maxDisplayTrack; i++) {
    if (i < trackNames.size()) {
      if (i == selectPosition) {
        fill(72, 98, 136);
        rect(0, (i * 1.2 + 0.2) * FONT_SIZE, width, FONT_SIZE * 1.2);
      }
      fill(255, 255, 255);
      text(trackNames.get(i + trackNum - selectPosition), FONT_SIZE, (i + 1) * FONT_SIZE * 1.2);
    }
  }
}

boolean shiftDownward() {
  if (selectPosition < maxDisplayTrack - 1 && selectPosition < trackNames.size() - 1) selectPosition++;
  if (trackNum < trackNames.size() - 1) {
    trackNum++;
    return true;
  }
  return false;
}

boolean shiftUpward() {
  if (selectPosition > 0) selectPosition--;
  if (trackNum > 0) {
    trackNum--;
    return true;
  }
  return false;
}

String selectedTrack() {
  return trackPaths.get(trackNames.get(trackNum));
}

boolean transitionToNextTrack(boolean looping) {
  if (looping) {
    if (trackNum == trackNames.size() - 1) {
      selectPosition = 0;
      trackNum = 0;
      return true;
    }
  }
  return shiftDownward();
}

boolean transitionToPrevTrack(boolean looping) {
  if (looping) {
    if (trackNum == 0) {
      selectPosition = maxDisplayTrack - 1;
      trackNum = trackNames.size() - 1;
      return true;
    }
  }
  return shiftUpward();
}

void displayTrackName(boolean looping) {
  text(trackNames.get(trackNum) + ((looping) ? " ⇄" : ""), FONT_SIZE, FONT_SIZE * 1.2);
}

void displayLoopState() {
  text("⇄", width - FONT_SIZE * 2.0, FONT_SIZE * 1.2);
}

void ascendingSort() {
  Collections.sort(trackNames);
}

void randomSort() {
  Collections.shuffle(trackNames);
}
