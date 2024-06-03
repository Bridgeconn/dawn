import React, { useEffect, useState } from 'react';
import { View, Text, TextInput,StyleSheet, Button } from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';
export default function TextBox() {

    const [jsonData,setJsonData]=useState([])
    const [paraNumber,setParaNumber]=useState(0)
    useEffect(() => {
      fetch('https://raw.githubusercontent.com/Bridgeconn/vachancontentrepository/master/obs/eng/content/01.md')
        .then(response => response.text())
        .then(text => {
        let jsonDataConvert:any=MdToJson(text)
        setJsonData(jsonDataConvert)
        })
        .catch(error => console.error('Error fetching the markdown file:', error));
    }, []);
    const MdToJson = (data: any) => {
      //convert md file text into json object
      //render story from json array object
      let story:any = [];
      let id = 0;
      const allLines = data.split(/\r\n|\n/);
      let title = "";
      let end = "";
      let error = "";
      // Reading line by line
      try {
        allLines.forEach((line:any) => {
          if (line) {
            if (line.match(/^#/gm)) {
              const hash = line.match(/# (.*)/);
              title = hash[1];
            } else if (line.match(/^_/gm)) {
              const underscore = line.match(/_(.*)_/);
              end = underscore[1];
            } else if (line.match(/^!/gm)) {
              id += 1;
              const imgUrl = line.match(/\((.*)\)/);
              story.push({
                id,
                url: imgUrl[1],
                text: ""
              });
            } else {
              story[id - 1].text = line;
            }
          }
        });
      } catch (e) {
        error = "Error parsing OBS md file text";
        title = "";
        end = "";
        story = [];
      }
    
      return { title, story, end, error };
    };
  let jsonLen=jsonData?jsonData?.story?.length:0
  return (
  <View style={styles.container2}>
    <View style={styles.container}>
     <Text>{jsonData?.length===0?"":jsonData?.story[paraNumber===jsonLen?0:paraNumber]?.id}{jsonData?.length===0?"":jsonData?.story[paraNumber===jsonLen?0:paraNumber]?.text}</Text>
   {paraNumber!==0 ?
     <Icon
      name="caret-left"
      size={35}
      color="black"
      onPress={()=>setParaNumber(paraNumber-1)}
    /> :""}
   {jsonData?.story?.length-1!==paraNumber ?
   <Icon
   name="caret-right"
   size={35}
   color="black"
   onPress={()=>setParaNumber(paraNumber!==jsonLen?paraNumber+1:0)}
 />
   :""}
    </View>
    <View
      style={{
        backgroundColor: '#fff',
        borderColor: 'lightgrey',
        borderWidth: 1,
        borderRadius:5
      }}>
      <TextInput
        placeholder='Add your text here'
        editable
        multiline
        numberOfLines={4}
        // onChangeText={text => onChangeText(text)}
        // value={value}
        style={{height:150,padding:5,backgroundColor:"lightgrey"}}
      />
    </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  container2: {
    flex: 1,
    justifyContent: 'center',padding: 10  },
    // btn:{
    //   flex:1
    // }
});
