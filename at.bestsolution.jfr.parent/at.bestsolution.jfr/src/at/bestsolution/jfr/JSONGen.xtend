package at.bestsolution.jfr

import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.resource.XtextResource
import java.util.ArrayList
import org.eclipse.emf.common.util.URI
import java.nio.file.Files
import java.nio.file.Paths
import at.bestsolution.jfr.jFRMeta.Model
import java.nio.file.StandardOpenOption
import at.bestsolution.jfr.jFRMeta.Clazz

import static extension at.bestsolution.jfr.GenUtil.*
import at.bestsolution.jfr.jFRMeta.Attribute

class JSONGen {
	def static void main(String[] args) {
		val versions = newArrayList("11","12","13","14","15","16","17")
		val injector = new JFRMetaStandaloneSetup().createInjectorAndDoEMFRegistration();
		val resourceSet = injector.getInstance(XtextResourceSet);
		resourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE);

		val models = new ArrayList
		for( v : versions ) {
			val resource = resourceSet.getResource(
			    URI.createURI("file:/Users/tomschindl/git/jfr-doc/openjdk-"+v+".jfr"), true);
			val model = resource.getContents().head as Model;
			models.add(model)
		}

		for( pair : models.indexed ) {
			val model = pair.value
			var version = versions.get(pair.key)
			val preModel = pair.key == 0 ? null : models.get(pair.key - 1)
			Files.writeString(Paths.get("/Users/tomschindl/git/jfr-doc/openjdk-"+version+".json"),model.generate(preModel,version), StandardOpenOption.TRUNCATE_EXISTING, StandardOpenOption.CREATE)
		}
	}

	def static generate(Model model, Model prevModel, String ver) '''
		{
			"version": "«ver»",
			"distribution": "openjdk",
			"events": [
				«val evts = model.classes.filter[c|c.super == "jdk.jfr.Event"]»
				«FOR e : evts»
					«e.generateEvent»«IF e !== evts.last»,«ENDIF»
				«ENDFOR»
			],
			"types": [
				«val types = model.classes.filter[c|c.super === null]»
				«FOR t : types»
					«t.generateType»«IF t !== types.last»,«ENDIF»
				«ENDFOR»
			]
		}
	'''

	def static generateEvent(Clazz clazz) '''
		{
			"name": "«clazz.name»",
			"description": "«clazz.description»",
			"label": "«clazz.label»",
			"categories": [
				«val cats = clazz.categories»
				«FOR cat : cats»
					"«cat»"«IF cat !== cats.last»,«ENDIF»
				«ENDFOR»
			],
			"attributes": [
				«FOR a : clazz.attributes»
					«a.generateAttribute»«IF a !== clazz.attributes.last»,«ENDIF»
				«ENDFOR»
			]
		}
	'''

	def static generateType(Clazz clazz) '''
		{
			"name": "«clazz.name»",
			"attributes": [
				«FOR a : clazz.attributes»
					«a.generateAttribute»«IF a !== clazz.attributes.last»,«ENDIF»
				«ENDFOR»
			]
		}
	'''

	def static generateAttribute(Attribute a) '''
		{
			"name": "«a.name»",
			"type": "«a.type.name»",
			"contentType": "«a.contentType»",
			"description": "«a.description»"
		}
	'''
}