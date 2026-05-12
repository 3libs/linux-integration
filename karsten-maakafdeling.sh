start() {
    clear #clear the terminal
    
   if [ -d "/$dirname" ]; then
      echo "directory /$dirname already exists."
      read dirname
      clear
      start
  fi
  
  }
